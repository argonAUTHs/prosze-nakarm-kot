import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oca_dart/oca_dart.dart';
import 'package:oca_dart/widget_data.dart';

import '../../domain/entities/request.dart';
import '../blocs/respond_to_request_bloc/respond_to_request_bloc.dart';
import '../blocs/respond_to_request_bloc/respond_to_request_event.dart';
import '../blocs/respond_to_request_bloc/respond_to_request_state.dart';

class RenderRequestView extends StatefulWidget {
  final WidgetData widgetData;
  final Request request;
  const RenderRequestView({Key? key, required this.widgetData, required this.request}) : super(key: key);

  @override
  State<RenderRequestView> createState() => _RenderRequestViewState();
}

class _RenderRequestViewState extends State<RenderRequestView> {
  @override
  Widget build(BuildContext context) {
    //var w = JsonWidgetData.fromDynamic(widget.widgetData.jsonData["elements"][0], registry: widget.widgetData.registry);
    //ValueNotifier<bool> counter = ValueNotifier<bool>(widget.widgetData.registry.getValue("form_validation"));
    Stream stream = OcaDartPlugin.returnValidationStream();
    stream.listen((event) {
      print(event);
      if(event == true){
        BlocProvider.of<RespondToRequestBloc>(context).add(RespondToRequest(widget.request));
      }else{
      }
    });
    return BlocListener<RespondToRequestBloc, RespondToRequestState>(
      listener: (event, state){
        if(state is RespondToRequestDone){
          Navigator.pushNamed(context, "/success").then((value) => Navigator.of(context).pop());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
            return true;
          },
          child: SafeArea(
              child: OcaDartPlugin.renderWidgetData(widget.widgetData, context)!
          ),
        ),
      ),
    );
  }
}