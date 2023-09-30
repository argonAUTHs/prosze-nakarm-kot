import '../../../domain/entities/acdc_db.dart';

abstract class PostAcdcToAuthorizeEvent{
  final AcdcDB? json;

  const PostAcdcToAuthorizeEvent({this.json});
}

class PostAcdcToAuthorize extends PostAcdcToAuthorizeEvent{
  const PostAcdcToAuthorize(AcdcDB json):super(json: json);
}