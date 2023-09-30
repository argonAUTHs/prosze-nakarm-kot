import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/render_form_from_request_bloc/render_form_from_request_event.dart';
import 'package:mobile/presentation/blocs/render_form_from_request_bloc/render_form_from_request_state.dart';
import 'package:oca_dart/widget_data.dart';

import '../../../domain/entities/request.dart';
import '../../../domain/usecases/render_form_from_request_usecase.dart';

class RenderFormFromRequestBloc extends Bloc<RenderFormFromRequestEvent, RenderFormFromRequestState>{
  final RenderFormFromRequestUseCase _renderFormFromRequestUseCase;
  RenderFormFromRequestBloc(this._renderFormFromRequestUseCase) : super(const RenderFormFromRequestInitial()) {
    on<RenderFormFromRequestEvent>((event, emit) async {
      await _codeHandler(emit, event.request!);
    });
  }

  Future<void> _codeHandler(Emitter<RenderFormFromRequestState> emit, Request request) async {
    emit(const RenderFormFromRequestLoading());
    try{
      WidgetData widgetData = await _renderFormFromRequestUseCase(params: request);
      emit(RenderFormFromRequestDone(widgetData));
    }catch(e){
      print(e);
      emit(const RenderFormFromRequestError());
    }
  }

}