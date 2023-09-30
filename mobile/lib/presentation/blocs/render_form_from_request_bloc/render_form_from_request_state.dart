import 'package:oca_dart/widget_data.dart';

abstract class RenderFormFromRequestState{
  final WidgetData? widgetData;
  const RenderFormFromRequestState({this.widgetData});
}

class RenderFormFromRequestInitial extends RenderFormFromRequestState{
  const RenderFormFromRequestInitial();
}

class RenderFormFromRequestLoading extends RenderFormFromRequestState{
  const RenderFormFromRequestLoading();
}

class RenderFormFromRequestDone extends RenderFormFromRequestState{
  const RenderFormFromRequestDone(WidgetData widgetData):super(widgetData: widgetData);
}

class RenderFormFromRequestError extends RenderFormFromRequestState{
  const RenderFormFromRequestError();
}