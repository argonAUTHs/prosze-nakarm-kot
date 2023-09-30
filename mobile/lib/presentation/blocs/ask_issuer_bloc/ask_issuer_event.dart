abstract class AskIssuerEvent{
  final String? params;
  const AskIssuerEvent({this.params});
}

class AskIssuer extends AskIssuerEvent{
  const AskIssuer(String params) : super(params: params);
}