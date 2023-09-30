import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/submit_form_bloc/submit_form_event.dart';
import 'package:mobile/presentation/blocs/submit_form_bloc/submit_form_state.dart';
import 'package:oca_dart/widget_data.dart';

import '../../../domain/entities/acdc_db.dart';
import '../../../domain/usecases/submit_form_usecase.dart';

class SubmitFormBloc extends Bloc<SubmitFormEvent, SubmitFormState>{
  final SubmitFormUseCase _submitFormUseCase;
  SubmitFormBloc(this._submitFormUseCase) : super(const SubmitFormInitial()) {
    on<SubmitFormEvent>((event, emit) async {
      await _codeHandler(emit, event.widgetData!);
    });
  }

  Future<void> _codeHandler(Emitter<SubmitFormState> emit, WidgetData widgetData) async {
    emit(const SubmitFormLoading());
    try{
      AcdcDB acdcDB = await _submitFormUseCase(params: widgetData);
      emit(SubmitFormDone(acdcDB));
    }catch(e){
      emit(const SubmitFormError());
    }
  }

}