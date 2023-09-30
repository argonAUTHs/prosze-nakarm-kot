abstract class RespondToRequestState{
  const RespondToRequestState();
}

class RespondToRequestInitial extends RespondToRequestState{
  const RespondToRequestInitial();
}

class RespondToRequestLoading extends RespondToRequestState{
  const RespondToRequestLoading();
}

class RespondToRequestDone extends RespondToRequestState{
  const RespondToRequestDone();
}

class RespondToRequestError extends RespondToRequestState{
  const RespondToRequestError();
}