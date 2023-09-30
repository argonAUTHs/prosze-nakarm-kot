import '../../../domain/entities/acdc_db.dart';

abstract class SaveAcdcEvent {
  final AcdcDB? acdc;
  const SaveAcdcEvent({this.acdc});
}

class SaveAcdc extends SaveAcdcEvent{
  const SaveAcdc(AcdcDB acdc):super(acdc: acdc);
}