import 'package:oca_dart/widget_data.dart';

import '../entities/acdc_db.dart';
import '../entities/request.dart';

abstract class AppRepository{
  Future<AcdcDB> submitForm(WidgetData widgetData);

  Future<void> saveAcdc(AcdcDB acdc);

  Future<String> postAcdcToAuthorize(AcdcDB acdcDB);

  Future<List<AcdcDB>> matchSchema(String json);

  Future<void> askIssuerForCredential(String params);

  Future<List<Request>> getRequestList();

  Future<void> respondToRequest(Request request);

  Future<WidgetData> renderFormFromRequest (Request request);
}