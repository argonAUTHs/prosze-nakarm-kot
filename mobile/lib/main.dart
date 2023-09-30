import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mobile/presentation/blocs/ask_issuer_bloc/ask_issuer_bloc.dart';
import 'package:mobile/presentation/blocs/match_schema_bloc/match_schema_bloc.dart';
import 'package:mobile/presentation/blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_bloc.dart';
import 'package:mobile/presentation/blocs/request_list_bloc/request_list_bloc.dart';
import 'package:mobile/presentation/blocs/respond_to_request_bloc/respond_to_request_bloc.dart';
import 'package:mobile/presentation/blocs/save_acdc_bloc/save_acdc_bloc.dart';
import 'package:mobile/presentation/blocs/submit_form_bloc/submit_form_bloc.dart';

import 'config/app_routes.dart';
import 'config/navigation_service.dart';
import 'injector.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
      MultiBlocProvider(
          providers: [
            BlocProvider<SubmitFormBloc>(
              create: (_) => injector<SubmitFormBloc>(),
            ),
            BlocProvider<SaveAcdcBloc>(
              create: (_) => injector<SaveAcdcBloc>(),
            ),
            BlocProvider<MatchSchemaBloc>(
              create: (_) => injector<MatchSchemaBloc>(),
            ),
            BlocProvider<PostAcdcToAuthorizeBloc>(
              create: (_) => injector<PostAcdcToAuthorizeBloc>(),
            ),
            BlocProvider<AskIssuerBloc>(
              create: (_) => injector<AskIssuerBloc>(),
            ),
            BlocProvider<RequestListBloc>(
              create: (_) => injector<RequestListBloc>(),
            ),
            BlocProvider<RespondToRequestBloc>(
              create: (_) => injector<RespondToRequestBloc>(),
            ),
          ],
          child: const MyApp()
      )
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayOpacity: 0.2,
      overlayWholeScreen: true,
      overlayWidget: const CircularProgressIndicator(
      ),
      child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: "Proszę, nakarm kot",
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          debugShowCheckedModeBanner: false
      ),
    );
  }
}