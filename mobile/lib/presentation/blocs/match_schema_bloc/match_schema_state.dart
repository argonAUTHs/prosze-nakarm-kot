import '../../../domain/entities/acdc_db.dart';

abstract class MatchSchemaState{
  final List<AcdcDB>? matches;

  const MatchSchemaState({this.matches});
}

class MatchSchemaInitial extends MatchSchemaState{
  const MatchSchemaInitial();
}

class MatchSchemaLoading extends MatchSchemaState{
  const MatchSchemaLoading();
}

class MatchSchemaDone extends MatchSchemaState{
  const MatchSchemaDone(List<AcdcDB> matches):super(matches: matches);
}

class MatchSchemaError extends MatchSchemaState{
  const MatchSchemaError();
}