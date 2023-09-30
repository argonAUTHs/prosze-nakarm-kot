import 'package:oca_dart/widget_data.dart';

abstract class SubmitFormEvent {
  final WidgetData? widgetData;
  const SubmitFormEvent({this.widgetData});
}

class SubmitForm extends SubmitFormEvent{
  const SubmitForm(WidgetData widgetData):super(widgetData: widgetData);
}