import '../../../domain/entities/request.dart';

abstract class RespondToRequestEvent{
  final Request? request;
  const RespondToRequestEvent({this.request});
}

class RespondToRequest extends RespondToRequestEvent{
  const RespondToRequest(Request request): super(request:request);
}