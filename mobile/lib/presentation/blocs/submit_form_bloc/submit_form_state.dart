import '../../../domain/entities/acdc_db.dart';

abstract class SubmitFormState{
  final AcdcDB? acdcDB;
  const SubmitFormState({this.acdcDB});
}

class SubmitFormLoading extends SubmitFormState{
  const SubmitFormLoading();
}

class SubmitFormDone extends SubmitFormState{
  const SubmitFormDone(AcdcDB acdcDB):super(acdcDB: acdcDB);
}

class SubmitFormError extends SubmitFormState{
  const SubmitFormError();
}

class SubmitFormInitial extends SubmitFormState{
  const SubmitFormInitial();
}