import 'package:bloc/bloc.dart';

import '../../../domain/usecases/ask_issuer_for_credential_usecase.dart';
import 'ask_issuer_event.dart';
import 'ask_issuer_state.dart';

class AskIssuerBloc extends Bloc<AskIssuerEvent, AskIssuerState>{
  final AskIssuerForCredentialUseCase _askIssuerForCredentialUseCase;

  AskIssuerBloc(this._askIssuerForCredentialUseCase):super(const AskIssuerInitial()){
    on<AskIssuerEvent>((event, emit) {
      if(event is AskIssuer){
        _createUserHandler(emit, event.params!);
      }
    });
  }


  Future<void> _createUserHandler(Emitter<AskIssuerState> emit,String params)async {
    emit(const AskIssuerLoading());
    try{
      await _askIssuerForCredentialUseCase(params: params);
      emit(const AskIssuerDone());
    }catch(e){
      print(e);
      print("ERROR???");
      emit(const AskIssuerError());
    }

  }
}