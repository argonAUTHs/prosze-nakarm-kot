import 'package:asymmetric_crypto_primitives/asymmetric_crypto_primitives.dart';
import 'package:asymmetric_crypto_primitives/ed25519_signer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:keri/keri.dart';
import 'package:mobile/presentation/blocs/ask_issuer_bloc/ask_issuer_bloc.dart';
import 'package:mobile/presentation/blocs/match_schema_bloc/match_schema_bloc.dart';
import 'package:mobile/presentation/blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_bloc.dart';
import 'package:mobile/presentation/blocs/render_form_from_request_bloc/render_form_from_request_bloc.dart';
import 'package:mobile/presentation/blocs/request_list_bloc/request_list_bloc.dart';
import 'package:mobile/presentation/blocs/respond_to_request_bloc/respond_to_request_bloc.dart';
import 'package:mobile/presentation/blocs/save_acdc_bloc/save_acdc_bloc.dart';
import 'package:mobile/presentation/blocs/submit_form_bloc/submit_form_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'data/datasources/database_service.dart';
import 'data/repositories/app_repository_impl.dart';
import 'domain/repositories/app_repository.dart';
import 'domain/usecases/ask_issuer_for_credential_usecase.dart';
import 'domain/usecases/get_request_list_usecase.dart';
import 'domain/usecases/match_schema_usecase.dart';
import 'domain/usecases/post_acdc_to_authorize_usecase.dart';
import 'domain/usecases/render_form_from_request_usecase.dart';
import 'domain/usecases/respond_to_request_usecase.dart';
import 'domain/usecases/save_acdc_usecase.dart';
import 'domain/usecases/submit_form_usecase.dart';

final injector = GetIt.instance;

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> initializeDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  var dir = await getLocalPath();
  if(prefs.getBool("firstTime") == null){
    prefs.setString("current_user", "default");
    prefs.setString("default_repo", "https://repository.oca.argo.colossi.network/api/oca-bundles/");
    prefs.setString("default_messagebox_size", "0");
    prefs.setString("default_nickname", "default_nickname");
    prefs.setStringList("default_inbox", []);
    prefs.setString("default_witness", "http://witness2.sandbox.argo.colossi.network/");
    Ed25519Signer signer = await createKeys("default", prefs);
    initializeKel(signer, "default", prefs);
    prefs.setBool("firstTime", false);
  }else{
    await initKel(inputAppDir: dir);
  }

  final databaseService = DatabaseService.db;
  final database = await databaseService.initDB();

  injector.registerSingleton<Database>(database, instanceName: "tda");
  injector.registerSingleton<SharedPreferences>(prefs);

  //DauthZ
  final dauthzDatabaseService = DatabaseService.db;
  final dauthzDatabase = await dauthzDatabaseService.initDB();
  const storage = FlutterSecureStorage();

  injector.registerSingleton<Database>(dauthzDatabase, instanceName: "dauthz");
  injector.registerSingleton<FlutterSecureStorage>(storage);
  injector.registerSingleton<AppRepository>(AppRepositoryImpl(injector(), injector.get(instanceName: "dauthz")));

  injector.registerSingleton<SubmitFormUseCase>(SubmitFormUseCase(injector()));
  injector.registerSingleton<SaveAcdcUseCase>(SaveAcdcUseCase(injector()));
  injector.registerSingleton<MatchSchemaUseCase>(MatchSchemaUseCase(injector()));
  injector.registerSingleton<PostAcdcToAuthorizeUseCase>(PostAcdcToAuthorizeUseCase(injector()));
  injector.registerSingleton<AskIssuerForCredentialUseCase>(AskIssuerForCredentialUseCase(injector()));
  injector.registerSingleton<GetRequestListUseCase>(GetRequestListUseCase(injector()));
  injector.registerSingleton<RenderFormFromRequestUseCase>(RenderFormFromRequestUseCase(injector()));
  injector.registerSingleton<RespondToRequestUseCase>(RespondToRequestUseCase(injector()));

  injector.registerFactory<SubmitFormBloc>(() => SubmitFormBloc(injector()));
  injector.registerFactory<SaveAcdcBloc>(() => SaveAcdcBloc(injector()));
  injector.registerFactory<MatchSchemaBloc>(() => MatchSchemaBloc(injector()));
  injector.registerFactory<PostAcdcToAuthorizeBloc>(() => PostAcdcToAuthorizeBloc(injector()));
  injector.registerFactory<AskIssuerBloc>(() => AskIssuerBloc(injector()));
  injector.registerFactory<RequestListBloc>(() => RequestListBloc(injector()));
  injector.registerFactory<RenderFormFromRequestBloc>(() => RenderFormFromRequestBloc(injector()));
  injector.registerFactory<RespondToRequestBloc>(() => RespondToRequestBloc(injector()));

}

//Creates identifier for given profile
Future<Identifier> initializeKel(Ed25519Signer signer, String name, SharedPreferences prefs) async{
  var dir = await getLocalPath();
  await initKel(inputAppDir: dir);
  List<PublicKey> vec1 = [];
  vec1.add((await newPublicKey(kt: KeyType.Ed25519, keyB64: await signer.getCurrentPubKey())));
  List<PublicKey> vec2 = [];
  vec2.add((await newPublicKey(kt: KeyType.Ed25519, keyB64: await signer.getNextPubKey())));
  String witnessLoc = prefs.getString("${name}_witness")!;
  List<String> vec3 = ["{\"eid\":\"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4\",\"scheme\":\"http\",\"url\":\"$witnessLoc\"}"];
  var icpEvent = await incept(
      publicKeys: vec1,
      nextPubKeys: vec2,
      witnesses: vec3,
      witnessThreshold: 1);
  print(icpEvent);
  var signature = await signer.signNoAuth(icpEvent);
  print("-----------------------------------------signature------------------------------------------");
  print(signature);
  var controller = await finalizeInception(
      event: icpEvent,
      signature: await signatureFromHex(
          st: SignatureType.Ed25519Sha512, signature: signature));

  try{
    await notifyWitnesses(identifier: controller);
    var query = await queryMailbox(whoAsk: controller, aboutWho: controller, witness: ["BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"]);
    print(query);
    var sigQuery = await signer.signNoAuth(query[0]);
    print(sigQuery);
    await finalizeQuery(identifier: controller, queryEvent: query[0], signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: sigQuery));

    RegistryData registryData = await inceptRegistry(identifier: controller);
    prefs.setString("${name}_registry", registryData.registryId);
    var registrySignatureHex = await signer.signNoAuth(registryData.ixn);
    await finalizeEvent(identifier: controller, event: registryData.ixn, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: registrySignatureHex));

    await notifyWitnesses(identifier: controller);
    var queryReg = await queryMailbox(whoAsk: controller, aboutWho: controller, witness: ["BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"]);
    print(query);
    var sigQueryReg = await signer.signNoAuth(queryReg[0]);
    print(sigQueryReg);
    await finalizeQuery(identifier: controller, queryEvent: queryReg[0], signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: sigQueryReg));

    String messageBoxOobi = "{\"eid\":\"BFY1nGjV9oApBzo5Oq5JqjwQsZEQqsCCftzo3WJjMMX-\",\"scheme\":\"http\",\"url\":\"http://messagebox.sandbox.argo.colossi.network/\"}";
    resolveOobi(oobiJson: messageBoxOobi);
    var addMessageBox = await addMessagebox(identifier: controller, messageboxOobi: messageBoxOobi);
    var addMessageBoxSig = await signer.signNoAuth(addMessageBox);
    await finalizeEvent(identifier: controller, event: addMessageBox, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: addMessageBoxSig));

    String addWatcherMessage = await addWatcher(controller: controller, watcherOobi: "{\"eid\":\"BF2t2NPc1bwptY1hYV0YCib1JjQ11k9jtuaZemecPF5b\",\"scheme\":\"http\",\"url\":\"http://watcher.sandbox.argo.colossi.network/\"}");
    print("********WATCHER MESSAGE*********");
    print(addWatcherMessage);
    String hexSig = await signer.signNoAuth(addWatcherMessage);
    print("********WATCHER SIGNATURE*********");
    print(hexSig);
    Signature addWatcherSignature = await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: hexSig);
    print("end role message signature: $hexSig");

    bool isFinalized = await finalizeEvent(identifier: controller, event: addWatcherMessage, signature: addWatcherSignature);
    print("%%%%%%%%%%%%%%%%%%%%%%IS FINALIZED???%%%%%%%%%%%%%%%%%%%%");
    print(isFinalized);

  }catch(e){
    print(e);
  }
  prefs.setString("${name}_identifier", controller.id);
  return controller;
}

//Creates Ed25519 keys for given profile
Future<Ed25519Signer> createKeys(String name, SharedPreferences prefs) async{
  Ed25519Signer signer = await AsymmetricCryptoPrimitives.establishForEd25519();
  print(signer.uuid);
  prefs.setString("${name}_uuid", signer.uuid);
  return signer;
}