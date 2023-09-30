import '../../core/usecases/future_usecase.dart';
import '../entities/acdc_db.dart';
import '../repositories/app_repository.dart';

class PostAcdcToAuthorizeUseCase implements FutureUseCase<String, AcdcDB>{
  final AppRepository _appRepository;
  PostAcdcToAuthorizeUseCase(this._appRepository);

  @override
  Future<String> call({required AcdcDB params}) async{
    return await _appRepository.postAcdcToAuthorize(params);
  }

}