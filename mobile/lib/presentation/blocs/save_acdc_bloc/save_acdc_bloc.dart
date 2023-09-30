import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/save_acdc_bloc/save_acdc_event.dart';
import 'package:mobile/presentation/blocs/save_acdc_bloc/save_acdc_state.dart';

import '../../../domain/entities/acdc_db.dart';
import '../../../domain/usecases/save_acdc_usecase.dart';

class SaveAcdcBloc extends Bloc<SaveAcdcEvent, SaveAcdcState>{
  final SaveAcdcUseCase _saveAcdcUseCase;
  SaveAcdcBloc(this._saveAcdcUseCase) : super(const SaveAcdcInitial()) {
    on<SaveAcdcEvent>((event, emit) async {
      await _codeHandler(emit, event.acdc!);
    });
  }

  Future<void> _codeHandler(Emitter<SaveAcdcState> emit, AcdcDB acdc) async {
    emit(const SaveAcdcLoading());
    try{
      await _saveAcdcUseCase(params: acdc);
      emit(const SaveAcdcDone());
    }catch(e){
      emit(const SaveAcdcError());
    }
  }

}