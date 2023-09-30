import 'package:bloc/bloc.dart';
import 'package:mobile/presentation/blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_event.dart';
import 'package:mobile/presentation/blocs/post_acdc_to_authorize_bloc/post_acdc_to_authorize_state.dart';

import '../../../domain/entities/acdc_db.dart';
import '../../../domain/usecases/post_acdc_to_authorize_usecase.dart';

class PostAcdcToAuthorizeBloc extends Bloc<PostAcdcToAuthorizeEvent, PostAcdcToAuthorizeState>{
  final PostAcdcToAuthorizeUseCase _postAcdcToAuthorizeUseCase;
  PostAcdcToAuthorizeBloc(this._postAcdcToAuthorizeUseCase) : super(const PostAcdcToAuthorizeInitial()) {
    on<PostAcdcToAuthorizeEvent>((event, emit) async {
      await _codeHandler(emit, event.json!);
    });
  }

  Future<void> _codeHandler(Emitter<PostAcdcToAuthorizeState> emit, AcdcDB json) async {
    emit(const PostAcdcToAuthorizeLoading());
    try{
      String response =  await _postAcdcToAuthorizeUseCase(params: json);
      print(response);
      emit(PostAcdcToAuthorizeDone(response));
    }catch(e){
      print(e);
      emit(const PostAcdcToAuthorizeError());
    }
  }

}