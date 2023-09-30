import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/respond_to_request_bloc/respond_to_request_event.dart';
import 'package:mobile/presentation/blocs/respond_to_request_bloc/respond_to_request_state.dart';

import '../../../domain/entities/request.dart';
import '../../../domain/usecases/respond_to_request_usecase.dart';

class RespondToRequestBloc extends Bloc<RespondToRequestEvent, RespondToRequestState>{
  final RespondToRequestUseCase _respondToRequestUseCase;
  RespondToRequestBloc(this._respondToRequestUseCase) : super(const RespondToRequestInitial()) {
    on<RespondToRequestEvent>((event, emit) async {
      await _codeHandler(emit, event.request!);
    });
  }

  Future<void> _codeHandler(Emitter<RespondToRequestState> emit, Request params) async {
    emit(const RespondToRequestLoading());
    try{
      await _respondToRequestUseCase(params: params);
      emit(const RespondToRequestDone());
    }catch(e){
      emit(const RespondToRequestError());
    }
  }

}