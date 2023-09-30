import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../domain/entities/acdc_db.dart';
import '../blocs/match_schema_bloc/match_schema_bloc.dart';
import '../blocs/match_schema_bloc/match_schema_event.dart';
import '../blocs/match_schema_bloc/match_schema_state.dart';
import '../blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_bloc.dart';
import '../blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_event.dart';
import '../blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_state.dart';
import 'authorized_view.dart';

class ScanToAuthorizeView extends StatefulWidget {
  const ScanToAuthorizeView({Key? key}) : super(key: key);

  @override
  State<ScanToAuthorizeView> createState() => _ScanToAuthorizeViewState();
}

class _ScanToAuthorizeViewState extends State<ScanToAuthorizeView> {
  //KEY FOR GETTING QR CODE
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  //RESULT OF SCANNING QR CODE
  Barcode? result;

  double fem = 1;
  double ffem = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
            color: Colors.blue,
            weight: 900
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_left, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scan QR code',
        ),
        centerTitle: true,
      ),
      body: BlocListener<MatchSchemaBloc, MatchSchemaState>(
        listener: (event, state){
          if(state is MatchSchemaDone){
            //Map<String, dynamic> json = jsonDecode(result!.code!);
            if(state.matches!.isNotEmpty){
              BlocProvider.of<PostAcdcToAuthorizeBloc>(context).add(PostAcdcToAuthorize(state.matches!.first));
            }else{
              if(context.loaderOverlay.visible==true){
                context.loaderOverlay.hide();
              }
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('There are no credentials saved on this device'),
                  content: const Text('You will be returned to the home screen.'),
                  actions: <Widget>[
                    Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                    )
                  ],
                ),
              ).then((value) => {
                controller?.dispose(),
                Navigator.of(context).pop()
              });
            }
          }else if(state is MatchSchemaError){
            if(context.loaderOverlay.visible==true){
              context.loaderOverlay.hide();
            }
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Credentials error'),
                content: const Text('You will be returned to the home screen.'),
                actions: <Widget>[
                  Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      )
                  )
                ],
              ),
            ).then((value) => {
              controller?.dispose(),
              Navigator.of(context).pop()
            });
          }
        },
        child: BlocListener<PostAcdcToAuthorizeBloc, PostAcdcToAuthorizeState>(
          listener: (event, state){
            if(state is PostAcdcToAuthorizeDone){
              if(context.loaderOverlay.visible==true){
                context.loaderOverlay.hide();
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AuthorizedView())).then((value) => Navigator.of(context).pop());
            }else if(state is PostAcdcToAuthorizeError){
              if(context.loaderOverlay.visible==true){
                context.loaderOverlay.hide();
              }
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Credential presenting failed'),
                  content: const Text('You will be returned to the home screen.'),
                  actions: <Widget>[
                    Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                    )
                  ],
                ),
              ).then((value) => {
                controller?.dispose(),
                Navigator.of(context).pop()
              });
            }
          },
          child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
              Positioned(
                left: MediaQuery.of(context).size.width/6,
                top: 50,
                child: Container(
                  margin:  EdgeInsets.fromLTRB(1*fem, 0*fem, 0*fem, 17*fem),
                  constraints:  BoxConstraints (
                    maxWidth:  235*fem,
                  ),
                  child:
                  Text(
                    'The app will automatically render the form after validating the credential.',
                    textAlign:  TextAlign.center,
                  ),
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 2.0, color: Colors.green),
                      color: Colors.transparent
                  ),
                  width: 256,
                  height: 256,
                ),
              ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.srcOut),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          backgroundBlendMode: BlendMode.dstOut),
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 2.0, color: Colors.green),
                            color: Colors.red
                        ),
                        width: 256,
                        height: 256,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        //context.loaderOverlay.show();
        BlocProvider.of<MatchSchemaBloc>(context).add(MatchSchema(result!.code!));
        dispose();
      });
    });
  }


  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}