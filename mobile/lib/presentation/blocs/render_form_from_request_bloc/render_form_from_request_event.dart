import '../../../domain/entities/request.dart';

abstract class RenderFormFromRequestEvent{
  final Request? request;

  const RenderFormFromRequestEvent({this.request});
}

class RenderFormFromRequest extends RenderFormFromRequestEvent{
  const RenderFormFromRequest(Request request) : super(request: request);
}