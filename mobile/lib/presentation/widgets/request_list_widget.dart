import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../domain/entities/request.dart';
import '../../injector.dart';
import '../blocs/render_form_from_request_bloc/render_form_from_request_bloc.dart';
import '../blocs/render_form_from_request_bloc/render_form_from_request_event.dart';
import '../blocs/render_form_from_request_bloc/render_form_from_request_state.dart';
import '../views/render_request_view.dart';

class RequestWidget extends StatefulWidget {
  final Request request;
  const RequestWidget({Key? key, required this.request}) : super(key: key);

  @override
  State<RequestWidget> createState() => _RequestWidgetState();
}

class _RequestWidgetState extends State<RequestWidget> {
  double fem = 1;
  double ffem = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (blocContext){
        return RenderFormFromRequestBloc(injector());
      },
      child: Builder(
          builder: (blocContext) {
            return BlocListener<RenderFormFromRequestBloc, RenderFormFromRequestState>(
              listener: (event, state){
                if(state is RenderFormFromRequestDone){
                  if(blocContext.loaderOverlay.visible==true){
                    blocContext.loaderOverlay.hide();
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RenderRequestView(widgetData: state.widgetData!, request: widget.request)));
                }else if(state is RenderFormFromRequestError){
                  if(blocContext.loaderOverlay.visible==true){
                    blocContext.loaderOverlay.hide();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request answering failed. Check the repo address.'), duration: Duration(milliseconds: 750),));
                }
              },
              child: Container(
                // keylistitemb3p (41:10)
                margin: EdgeInsets.fromLTRB(0 * fem, 9 * fem, 0 * fem, 9 * fem),
                //padding: EdgeInsets.fromLTRB(10 * fem, 19 * fem, 9 * fem, 19 * fem),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * fem),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 37 * fem, 10 * fem),
                        constraints: BoxConstraints(
                          maxWidth: 327 * fem,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "From: ${jsonDecode(widget.request.oobi)["cid"]}",
                            ),
                            Text(
                              "Schema id: ${widget.request.schema}",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        //margin: EdgeInsets.fromLTRB(248 * fem, 0 * fem, 0 * fem, 0 * fem),
                        width: double.infinity,
                        height: 48 * fem,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async{
                                // blocContext.loaderOverlay.show();
                                BlocProvider.of<RenderFormFromRequestBloc>(blocContext).add(RenderFormFromRequest(widget.request));
                                // BlocProvider.of<ShareAcdcBloc>(blocContext).add(ShareAcdc(widget.acdcDB));
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(7 * fem, 7 * fem, 7 * fem, 7 * fem),
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  color: const Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(24 * fem),
                                ),
                                child: Center(
                                  // qrcodeFAJ (41:23)
                                  child: SizedBox(
                                    width: 34 * fem,
                                    height: 34 * fem,
                                    child: const Icon(
                                      Icons.file_copy_outlined,
                                      color: Colors.blue,
                                      size: 35,
                                    ),
                                  ),
                                ),
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
      ),
    );
  }

}