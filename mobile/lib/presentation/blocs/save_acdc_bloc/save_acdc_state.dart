abstract class SaveAcdcState{
  const SaveAcdcState();
}

class SaveAcdcInitial extends SaveAcdcState{
  const SaveAcdcInitial();
}

class SaveAcdcLoading extends SaveAcdcState{
  const SaveAcdcLoading();
}

class SaveAcdcDone extends SaveAcdcState{
  const SaveAcdcDone();
}

class SaveAcdcError extends SaveAcdcState{
  const SaveAcdcError();
}