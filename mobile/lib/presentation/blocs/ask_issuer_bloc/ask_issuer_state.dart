abstract class AskIssuerState {
  const AskIssuerState();
}

class AskIssuerInitial extends AskIssuerState{
  const AskIssuerInitial();
}

class AskIssuerLoading extends AskIssuerState{
  const AskIssuerLoading();
}

class AskIssuerDone extends AskIssuerState{
  const AskIssuerDone();
}

class AskIssuerError extends AskIssuerState{
  const AskIssuerError();
}