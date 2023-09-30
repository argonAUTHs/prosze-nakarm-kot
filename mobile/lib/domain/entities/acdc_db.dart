import 'package:acdc/bridge_generated.dart';

class AcdcDB{
  final ACDC acdc;
  final String signature;
  final String dateIssued;
  final String metaDescription;
  final String oobi;
  String? endpoint;
  final String profile;
  final String issued;

  AcdcDB({required this.acdc, required this.signature, required this.dateIssued, required this.metaDescription, required this.oobi, this.endpoint, required this.profile, required this.issued});
}