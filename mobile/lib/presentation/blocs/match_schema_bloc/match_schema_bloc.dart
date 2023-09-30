import 'package:bloc/bloc.dart';

import '../../../domain/entities/acdc_db.dart';
import '../../../domain/usecases/match_schema_usecase.dart';
import 'match_schema_event.dart';
import 'match_schema_state.dart';

class MatchSchemaBloc extends Bloc<MatchSchemaEvent, MatchSchemaState>{
  final MatchSchemaUseCase _matchSchemaUseCase;
  MatchSchemaBloc(this._matchSchemaUseCase) : super(const MatchSchemaInitial()) {
    on<MatchSchemaEvent>((event, emit) async {
      await _codeHandler(emit, event.schema!);
    });
  }

  Future<void> _codeHandler(Emitter<MatchSchemaState> emit, String schema) async {
    emit(const MatchSchemaLoading());
    try{
      List<AcdcDB> matches =  await _matchSchemaUseCase(params: schema);
      print(matches.length);
      emit(MatchSchemaDone(matches));
    }catch(e){
      print(e);
      emit(const MatchSchemaError());
    }
  }

}