import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/request_list_bloc/request_list_event.dart';
import 'package:mobile/presentation/blocs/request_list_bloc/request_list_state.dart';

import '../../../domain/entities/request.dart';
import '../../../domain/usecases/get_request_list_usecase.dart';

class RequestListBloc extends Bloc<RequestListEvent, RequestListState>{
  final GetRequestListUseCase _getRequestListUseCase;

  RequestListBloc(this._getRequestListUseCase):super(const RequestListInitial()){
    on<RequestListEvent>((event, emit) {
      if(event is GetRequestList){
        _handler(emit);
      }
    });
  }


  Future<void> _handler(Emitter<RequestListState> emit)async {
    emit(const RequestListLoading());
    try{
      List<Request> requestList = await _getRequestListUseCase();
      emit(RequestListDone(requestList));
    }catch(e){
      print(e);
      print("ERROR???");
      emit(const RequestListError());
    }

  }
}