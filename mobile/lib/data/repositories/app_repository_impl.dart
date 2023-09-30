import 'dart:convert';

import 'package:acdc/acdc.dart';
import 'package:acdc/bridge_generated.dart';
import 'package:asymmetric_crypto_primitives/asymmetric_crypto_primitives.dart';
import 'package:asymmetric_crypto_primitives/ed25519_signer.dart';
import 'package:intl/intl.dart';
import 'package:keri/keri.dart';
import 'package:mobile/domain/entities/acdc_db.dart';

import 'package:mobile/domain/entities/request.dart';
import 'package:oca_dart/oca_dart.dart';
import 'package:oca_dart/widget_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/repositories/app_repository.dart';

import 'package:http/http.dart' as http;

class AppRepositoryImpl implements AppRepository{
  final SharedPreferences preferences;
  final Database _database;
  AppRepositoryImpl(this.preferences, this._database);

  //Submits the rendered form and issues the credential
  @override
  Future<AcdcDB> submitForm(WidgetData widgetData) async{
    print("---------------Preferences--------------");
    print(preferences.getKeys());
    print("weszło");
    Map<String, dynamic> obtainedResults = OcaDartPlugin.returnObtainedValues();
    print(obtainedResults);
    String currentUser = preferences.getString("current_user")!;
    //Ed25519Signer signer = await checkIfKeysCreated();
    print(preferences.getString("${currentUser}_identifier")!);
    // try{
    //   Ed25519Signer signer = await AsymmetricCryptoPrimitives.getEd25519SignerFromUuid(preferences.getString("${currentUser}_uuid")!);
    // }catch(e){
    //   print(e);
    // }


    Ed25519Signer signer = await AsymmetricCryptoPrimitives.getEd25519SignerFromUuid(preferences.getString("${currentUser}_uuid")!);
    print(signer.uuid);
    //Identifier identifier = await checkIfKelInitialized(signer);
    Identifier identifier = await newIdentifier(idStr: preferences.getString("${currentUser}_identifier")!);
    print(identifier.id);
    print(OcaDartPlugin.returnSchemaId(widgetData));
    // try{
    //   ACDC acdc = await Acdc.issuePrivateUntargetedStaticMethodAcdc(issuer: identifier.id, schema: OcaDartPlugin.returnSchemaId(widgetData), attributes: jsonEncode(obtainedResults), registryId: preferences.getString("${currentUser}_registry")!);
    // }catch(e){
    //   print(e);
    // }
    ACDC acdc = await Acdc.issuePrivateUntargetedStaticMethodAcdc(issuer: identifier.id, schema: OcaDartPlugin.returnSchemaId(widgetData), attributes: jsonEncode(obtainedResults), registryId: preferences.getString("${currentUser}_registry")!);
    print(acdc);
    String encoded = await Acdc.encodeMethodAcdc(that: acdc);
    print(encoded);

    IssuanceData issuanceData = await issueCredential(identifier: identifier, credential: encoded);
    String issuanceSig = await signer.signNoAuth(issuanceData.ixn);
    await finalizeEvent(identifier: identifier, event: issuanceData.ixn, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: issuanceSig));
    await notifyWitnesses(identifier: identifier);
    var query2 = await queryMailbox(whoAsk: identifier, aboutWho: identifier, witness: ["BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"]);
    print(query2);
    var sigQuery2 = await signer.signNoAuth(query2[0]);
    print(sigQuery2);
    await finalizeQuery(identifier: identifier, queryEvent: query2[0], signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: sigQuery2));
    await notifyBackers(identifier: identifier);
    print("*******CREDENTIAL STATE*******");
    print(await getCredentialState(identifier: identifier, credentialSaid: issuanceData.vcId));

    String issuanceData2 = await revokeCredential(identifier: identifier, credentialSaid: issuanceData.vcId);
    String issuanceSig2 = await signer.signNoAuth(issuanceData2);
    await finalizeEvent(identifier: identifier, event: issuanceData2, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: issuanceSig2));
    await notifyWitnesses(identifier: identifier);
    var query22 = await queryMailbox(whoAsk: identifier, aboutWho: identifier, witness: ["BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"]);
    print(query22);
    var sigQuery22 = await signer.signNoAuth(query22[0]);
    print(sigQuery22);
    await finalizeQuery(identifier: identifier, queryEvent: query22[0], signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: sigQuery22));
    await notifyBackers(identifier: identifier);
    print("*******CREDENTIAL STATE*******");
    print(await getCredentialState(identifier: identifier, credentialSaid: issuanceData.vcId));

    String signature = await signer.sign(encoded);
    print(signature);
    String signedToCesr = await signToCesr(identifier: identifier, data: encoded, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: signature));

    print("SIGNED TO CESR:");
    print("////////////////////////////////////////////////////////////////////////");
    print(signedToCesr);
    try{
      //print("Dodatkowa weryfikacja:");
      //print(await verifyFromCesr(stream: '{"v":"ACDC10JSON000126_","d":"EEutKtSBoWqsalzBVLcaLv7Xjb1EDh3s2v5tH04zDgL-","i":"EKKtqnGaeOb_gddEZp7UFiLtCVvF_HEHO9874nOSLNV8","ri":"","s":"EPtdQc35vLxszRMw3-uyBg3JY0_7uQ0xqZlkCfD0VSB5","a":{"d":"EHOPEKTXmoLdQ9rjS evhOOYSVFol3f1UVc4o63_pk9nV","u":"0ACQmcdJPwdIy63uCoRiI8ol","a":{"passed":true}}}-FABEKKtqnGaeOb_gddEZp7UFiLtCVvF_HEHO9874nOSLNV80AAAAAAAAAAAAAAAAAAAAAABEIsqHfWk4zZ2umLFEmITmqDiZM3c0Yd5Jss7471c9moM-AABAACNwdnpbMVqGT8_saAfXXi0gT5aTw0 5PBk3sTjH1pjXaICp5GFVRq-pSzMiOrMhIlW-DtqLqFixztaNAWLIPLAB'));
      print(await verifyFromCesr(stream: signedToCesr));
    }catch(e){
      print(e);
    }

    print("#####META######");
    print(OcaDartPlugin.returnMetaDescription(widgetData));
    String oobi = '{"cid":"${identifier.id}","role":"witness","eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"}';
    return AcdcDB(acdc: acdc, signature: signedToCesr.substring(signedToCesr.indexOf('}}-')+3, signedToCesr.length), dateIssued:  DateFormat('dd-MM-yyyy').format(DateTime.now()), metaDescription: OcaDartPlugin.returnMetaDescription(widgetData), oobi: oobi, profile: currentUser, issued: "issued");

  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  //Saves the given acdc to the database
  @override
  Future<void> saveAcdc(AcdcDB acdc) async {
    try{
      final db = _database;
      await db.rawInsert(
          'INSERT INTO acdc (issuer, data, schema, signature, date_issued, meta_description, oobi, profile, issued, acdcJson) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [await acdc.acdc.getIssuer(), await acdc.acdc.getAttributes(), await acdc.acdc.getSchema(), acdc.signature, acdc.dateIssued, acdc.metaDescription, acdc.oobi, acdc.profile, acdc.issued, await Acdc.encodeMethodAcdc(that: acdc.acdc)]);
    }catch(e){
      print(e);
    }
  }

  //Generates a credential String to authorize to a service
  Future<String> generateAcdcToAuthorize(AcdcDB acdcDB) async{
    var acdc = await Acdc.encodeMethodAcdc(that: acdcDB.acdc);
    var signature = acdcDB.signature;

    String currentUser = preferences.getString("current_user")!;
    String identifierString = preferences.getString("${currentUser}_identifier")!;
    String signerUuid = preferences.getString("${currentUser}_uuid")!;

    Ed25519Signer signer = await AsymmetricCryptoPrimitives.getEd25519SignerFromUuid(signerUuid);
    String holderOobi = '{"cid":"$identifierString","role":"witness","eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"}';
    String oobi = acdcDB.oobi;
    String secondSignature = await signer.signNoAuth(acdc);
    String signedToCesr = await signToCesr(identifier: await newIdentifier(idStr: identifierString), data: acdc, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: secondSignature));
    String holderSignature = signedToCesr.substring(signedToCesr.indexOf('}}-')+3, signedToCesr.length);



    print("$oobi$holderOobi$acdc-$signature-$holderSignature");
    return "$oobi$holderOobi$acdc";
  }

  //Sends the credential to a provided by QR endpoint to authorize to a service
  @override
  Future<String> postAcdcToAuthorize(AcdcDB acdcDB) async{


    Uri endpoint = Uri.parse(acdcDB.endpoint!);
    print("endpoint!!");
    print(endpoint);
    String correctACDC = await generateAcdcToAuthorize(acdcDB);
    final response = await http.post(endpoint, body: correctACDC);
    if(response.statusCode == 200){
      print(response.body);
      return ("works");
    }else{
      return ("does not work");
    }
  }

  //Selects the credentials that match the given schema
  @override
  Future<List<AcdcDB>> matchSchema(String json) async{
    SplittingResult oobis = await splitOobisAndData(stream: jsonDecode(json)["o"]);
    for(String oobi in oobis.oobis){
      print("tutaj");
      print(oobi);
      await resolveOobi(oobiJson: oobi);
    }
    print("będzie mailbox");
    print(jsonDecode(oobis.oobis[1])["cid"]);
    print(await getMessagebox(whose: jsonDecode(oobis.oobis[1])["cid"]));
    String mailboxLocation = (await getMessagebox(whose: jsonDecode(oobis.oobis[1])["cid"]))[0];
    print("mailbox:");
    print(mailboxLocation);

    String mailboxUrl = "${jsonDecode(mailboxLocation)["url"]}${jsonDecode(oobis.oobis[1])["cid"]}";
    print(mailboxUrl);

    String schemaSaid = jsonDecode(json)["s"];
    List<AcdcDB> correctACDCs = [];
    for (AcdcDB a in await getAllAcdcsByProfile()){
      if(await a.acdc.getSchema() == schemaSaid){
        //print(await generateQRCode(a));
        //TU ZMIENIONE!!!
        a.endpoint = mailboxUrl;
        correctACDCs.add(a);
      }
    }
    print("MATCHED!!!");
    print(correctACDCs.map((e) => e.endpoint));
    return correctACDCs;
  }

  //Checks whether the credential was issued by this user or scanned and received.
  Future<bool> checkIfAcdcImported(String currentUser, String digest) async{
    final db = _database;
    // Query the table for all The Passwords.
    final List<Map<String, dynamic>> maps = await db.query('acdc');
    // Convert the List<Map<String, dynamic> into a List<PasswordModel>.
    List<AcdcDB> acdcs=[];

    for (int i=0; i<maps.length; i++){
      if(maps[i]["profile"] == currentUser){
        var acdc = await Acdc.parseStaticMethodAcdc(stream: maps[i]['acdcJson']);
        acdcs.add(AcdcDB(acdc: acdc, signature: maps[i]['signature'], dateIssued: maps[i]['date_issued'], metaDescription: maps[i]['meta_description'], oobi: maps[i]['oobi'], profile: maps[i]['profile'], issued: maps[i]["issued"]));
        print(await Acdc.encodeMethodAcdc(that: acdc));
      }
    }
    for(AcdcDB acdcDB in acdcs){
      if(await acdcDB.acdc.getDigest() == digest){
        return true;
      }
    }
    return false;
  }

  //Returns the list of all acdcs for given profile, both those from the database and the cred agent.
  Future<List<AcdcDB>> getAllAcdcsByProfile() async {
    String currentUser = preferences.getString("current_user")!;
    String identifierString = preferences.getString(
        "${currentUser}_identifier")!;
    Identifier identifier = await newIdentifier(idStr: identifierString);
    Ed25519Signer signer = await AsymmetricCryptoPrimitives
        .getEd25519SignerFromUuid(
        preferences.getString("${currentUser}_uuid")!);

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    print("będzie mailbox");
    print(await getMessagebox(whose: identifierString));
    String mailboxLocation = (await getMessagebox(whose: identifierString))[0];
    print("mailbox:");
    print(mailboxLocation);

    String mailboxUrl = "${jsonDecode(
        mailboxLocation)["url"]}$identifierString";
    print(mailboxUrl);

    final response = await http.get(Uri.parse(mailboxUrl), headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      String resp = const Utf8Decoder().convert(response.bodyBytes);
      print(jsonDecode(resp));
      for (dynamic entry in jsonDecode(resp)) {
        if (jsonDecode(entry)["r"] == "credential") {
          String acdc = jsonEncode((jsonDecode(entry))["a"][0]) +
              jsonEncode((jsonDecode(entry))["a"][1]);
          print(acdc);
          SplittingResult splittingResult = await splitOobisAndData(
              stream: acdc);
          await sendOobiToWatcher(
              identifier: identifier, oobisJson: splittingResult.oobis[0])
              .then((value) async {
            print(value);
            var query = await queryWatchers(whoAsk: identifier,
                aboutWho: await newIdentifier(
                    idStr: jsonDecode(splittingResult.oobis[0])["cid"]));
            print(query);
            var sig = await signer.signNoAuth(query[0]);
            print(sig);
            await finalizeQuery(
                identifier: identifier,
                queryEvent: query[0],
                signature: await signatureFromHex(
                    st: SignatureType.Ed25519Sha512, signature: sig));
          });

          ACDC acdcFromJson = await Acdc.parseStaticMethodAcdc(
              stream: jsonEncode((jsonDecode(entry))["a"][1]));
          String schema = await acdcFromJson.getSchema();
          var file = await OcaDartPlugin.getJsonFromHttp(
              '${preferences.getString("${currentUser}_repo")!}$schema');
          print(OcaDartPlugin.returnMetaDescription(
              jsonDecode(const Utf8Decoder().convert(file))));
          AcdcDB acdcDB = AcdcDB(acdc: acdcFromJson,
              signature: 'signature',
              dateIssued: DateFormat('dd-MM-yyyy').format(DateTime.now()),
              metaDescription: OcaDartPlugin.returnMetaDescription(
                  jsonDecode(const Utf8Decoder().convert(file))),
              oobi: splittingResult.oobis[0],
              profile: currentUser,
              issued: "imported");
          if (await checkIfAcdcImported(
              currentUser, await acdcDB.acdc.getDigest()) != true) {
            await saveAcdc(acdcDB);
          }
        }
      }
    }
    final db = _database;
    // Query the table for all The Passwords.
    final List<Map<String, dynamic>> maps = await db.query('acdc');
    // Convert the List<Map<String, dynamic> into a List<PasswordModel>.
    List<AcdcDB> acdcs=[];

    for (int i=0; i<maps.length; i++){
      if(maps[i]["profile"] == currentUser){
        var acdc = await Acdc.parseStaticMethodAcdc(stream: maps[i]['acdcJson']);
        acdcs.add(AcdcDB(acdc: acdc, signature: maps[i]['signature'], dateIssued: maps[i]['date_issued'], metaDescription: maps[i]['meta_description'], oobi: maps[i]['oobi'], profile: maps[i]['profile'], issued: maps[i]["issued"]));
        print(await Acdc.encodeMethodAcdc(that: acdc));
      }
    }
    return acdcs;
  }

  @override
  Future<void> askIssuerForCredential(String params) async{
    String currentUser = preferences.getString("current_user")!;
    //Ed25519Signer signer = await checkIfKeysCreated();
    Ed25519Signer signer = await AsymmetricCryptoPrimitives.getEd25519SignerFromUuid(preferences.getString("${currentUser}_uuid")!);
    print(signer.uuid);
    //Identifier identifier = await checkIfKelInitialized(signer);
    await newIdentifier(idStr: preferences.getString("${currentUser}_identifier")!);
    // Ed25519Signer signer = await checkIfKeysCreated();
    // print(signer.uuid);
    // Identifier identifier = await checkIfKelInitialized(signer);
    // String currentUser = preferences.getString("current_user")!;
    String identifierString = preferences.getString("${currentUser}_identifier")!;

    SplittingResult oobis = await splitOobisAndData(stream: jsonDecode(params)["i"]);
    for(String oobi in oobis.oobis){
      print("tutaj");
      print(oobi);
      await resolveOobi(oobiJson: oobi);
    }
    print("będzie mailbox");
    print(jsonDecode(oobis.oobis[1])["cid"]);
    print(await getMessagebox(whose: jsonDecode(oobis.oobis[1])["cid"]));
    String mailboxLocation = (await getMessagebox(whose: jsonDecode(oobis.oobis[1])["cid"]))[0];
    print("mailbox:");
    print(mailboxLocation);

    String mailboxUrl = "${jsonDecode(mailboxLocation)["url"]}${jsonDecode(oobis.oobis[1])["cid"]}";
    print(mailboxUrl);

    final response = await http.post(Uri.parse(mailboxUrl), body: '{"r":"cred-request","s":"${jsonDecode(params)["s"]}","o":{"cid":"$identifierString","role":"witness","eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"},"m":[${(await getMessagebox(whose: identifierString))[0]},{"cid":"$identifierString","role":"messagebox","eid":"BFY1nGjV9oApBzo5Oq5JqjwQsZEQqsCCftzo3WJjMMX-"}]}');
    print(response.statusCode);
    print(response.body);
  }

  //Returns the list of credential requests for current user
  @override
  Future<List<Request>> getRequestList() async{
    String? currentUser = preferences.getString("current_user");

    if(currentUser == null){
      return [];
    }
    String identifierString = preferences.getString("${currentUser}_identifier")!;

    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    String messageBox = (await getMessagebox(whose: identifierString))[0];
    String messageBoxUrl = "${jsonDecode(messageBox)["url"]}$identifierString";

    final response = await http.get(Uri.parse(messageBoxUrl), headers: headers);

    print("The list");
    print(response.body);
    if(response.statusCode==200){
      List<dynamic> resp = jsonDecode(response.body);
      print(resp);
      List<Request> requestList = [];
      for(dynamic entry in resp){
        if(jsonDecode(entry)["s"] != null){
          print("ENTRY MMMMMM");
          print(jsonDecode(entry)["s"]);
          print(jsonDecode(entry)["o"]);
          print(jsonDecode(entry)["m"]);
          String mailboxOobis = '';
          for (dynamic item in jsonDecode(entry)["m"]){
            mailboxOobis = mailboxOobis + jsonEncode(item);
            print(mailboxOobis);
          }
          requestList.add(Request(schema: jsonDecode(entry)["s"].toString(), oobi: jsonEncode(jsonDecode(entry)["o"]), mailboxOobi: mailboxOobis));
        }
      }
      return requestList;
    }else{
      return [];
    }

  }


  //Submits the form that was requested from the holder
  @override
  Future<void> respondToRequest(Request request) async{
    Map<String, dynamic> obtainedResults = OcaDartPlugin.returnObtainedValues();
    print(obtainedResults);
    // Ed25519Signer signer = await checkIfKeysCreated();
    // print(signer.uuid);
    // Identifier identifier = await checkIfKelInitialized(signer);
    String currentUser = preferences.getString("current_user")!;
    //Ed25519Signer signer = await checkIfKeysCreated();
    Ed25519Signer signer = await AsymmetricCryptoPrimitives.getEd25519SignerFromUuid(preferences.getString("${currentUser}_uuid")!);
    print(signer.uuid);
    //Identifier identifier = await checkIfKelInitialized(signer);
    Identifier identifier = await newIdentifier(idStr: preferences.getString("${currentUser}_identifier")!);

    try{
      await sendOobiToWatcher(identifier: identifier, oobisJson: jsonEncode({"eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4","scheme":"http","url":"http://witness2.sandbox.argo.colossi.network/"}));
    }catch(e){
      print("sending new oobi failed:");
      print(e);
    }

    try{
      await sendOobiToWatcher(identifier: identifier, oobisJson: request.oobi).then((value) async{
        print(value);
        var query = await queryWatchers(whoAsk: identifier, aboutWho: await newIdentifier(idStr: jsonDecode(request.oobi)["cid"]));
        print(query);
        var sig = await signer.signNoAuth(query[0]);
        print(sig);
        await finalizeQuery(
            identifier: identifier,
            queryEvent: query[0],
            signature: await signatureFromHex(
                st: SignatureType.Ed25519Sha512, signature: sig));
      });

      SplittingResult oobis = await splitOobisAndData(stream: request.mailboxOobi);
      for(String oobi in oobis.oobis){
        print("tutaj");
        print(oobi);
        await resolveOobi(oobiJson: oobi);
      }

      ACDC acdc = await Acdc.issuePrivateTargetedStaticMethodAcdc(issuer: identifier.id, target: jsonDecode(request.oobi)["cid"], schema: request.schema, attributes: jsonEncode(obtainedResults), registryId: preferences.getString("${currentUser}_registry")!);

      print("będzie mailbox");
      print(jsonDecode(oobis.oobis[1])["cid"]);
      print(await getMessagebox(whose: jsonDecode(request.oobi)["cid"]));
      String mailboxLocation = (await getMessagebox(whose: jsonDecode(request.oobi)["cid"]))[0];
      print("mailbox:");
      print(mailboxLocation);

      String mailboxUrl = "${jsonDecode(mailboxLocation)["url"]}${jsonDecode(oobis.oobis[1])["cid"]}";
      print(mailboxUrl);

      String holderKel = await getKel(cont: await newIdentifier(idStr: jsonDecode(request.oobi)["cid"]));
      //String mailboxLocation = "http://cred-agent.sandbox.argo.colossi.network/${jsonDecode(request.oobi)["cid"]}";
      print(acdc);
      String encoded = await Acdc.encodeMethodAcdc(that: acdc);
      print(encoded);

      IssuanceData issuanceData = await issueCredential(identifier: identifier, credential: encoded);
      String issuanceSig = await signer.signNoAuth(issuanceData.ixn);
      await finalizeEvent(identifier: identifier, event: issuanceData.ixn, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: issuanceSig));
      await notifyWitnesses(identifier: identifier);
      var query2 = await queryMailbox(whoAsk: identifier, aboutWho: identifier, witness: ["BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"]);
      print(query2);
      var sigQuery2 = await signer.signNoAuth(query2[0]);
      print(sigQuery2);
      await finalizeQuery(identifier: identifier, queryEvent: query2[0], signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: sigQuery2));
      await notifyBackers(identifier: identifier);
      print("*******CREDENTIAL STATE*******");
      print(await getCredentialState(identifier: identifier, credentialSaid: issuanceData.vcId));

      String signature = await signer.sign(encoded);
      print(signature);
      String signedToCesr = await signToCesr(identifier: identifier, data: encoded, signature: await signatureFromHex(st: SignatureType.Ed25519Sha512, signature: signature));

      String oobi = '{"cid":"${identifier.id}","role":"witness","eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4"}';
      String schema = await acdc.getSchema();
      var file = await OcaDartPlugin.getJsonFromHttp('${preferences.getString("${currentUser}_repo")!}$schema');
      print(OcaDartPlugin.returnMetaDescription(jsonDecode(const Utf8Decoder().convert(file))));
      AcdcDB acdcDB = AcdcDB(acdc: acdc, signature: signature, dateIssued: DateFormat('dd-MM-yyyy').format(DateTime.now()), metaDescription: OcaDartPlugin.returnMetaDescription(jsonDecode(const Utf8Decoder().convert(file))), oobi: oobi, profile: currentUser!, issued: "issued");
      await saveAcdc(acdcDB);
      print('{"r":"credential","a":[$oobi,$encoded]}');
      await http.post(Uri.parse(mailboxUrl), body: '{"r":"credential","a":[$oobi,$encoded]}');
    }catch(e){
      print(e);
    }
  }

  //Issuer answers the request from the holder. Renders a form for the issuer to submit.
  @override
  Future<WidgetData> renderFormFromRequest(Request request) async{
    String? currentUser = preferences.getString("current_user");
    String identifier = preferences.getString("${currentUser}_identifier")!;
    var credLocation = preferences.getString("${currentUser}_repo");
    var file = await OcaDartPlugin.getJsonFromHttp("$credLocation${request.schema}");
    print(const Utf8Decoder().convert(file));
    WidgetData widgetData = await OcaDartPlugin.getWidgetData(const Utf8Decoder().convert(file), identifier);
    return widgetData;
  }

  
}