import '../../core/usecases/future_usecase.dart';
import '../repositories/app_repository.dart';

class AskIssuerForCredentialUseCase implements FutureUseCase<void, String>{
  final AppRepository _appRepository;
  AskIssuerForCredentialUseCase(this._appRepository);

  @override
  Future<void> call({required String params}) async{
    await _appRepository.askIssuerForCredential(params);
  }

}