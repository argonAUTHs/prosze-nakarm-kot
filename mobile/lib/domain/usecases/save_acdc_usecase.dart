import '../../core/usecases/future_usecase.dart';
import '../entities/acdc_db.dart';
import '../repositories/app_repository.dart';

class SaveAcdcUseCase implements FutureUseCase<void, AcdcDB>{
  final AppRepository _appRepository;
  SaveAcdcUseCase(this._appRepository);

  @override
  Future<void> call({required AcdcDB params}) async{
    return await _appRepository.saveAcdc(params);
  }

}