import '../../core/usecases/future_usecase.dart';
import '../entities/request.dart';
import '../repositories/app_repository.dart';

class RespondToRequestUseCase implements FutureUseCase <void, Request>{
  final AppRepository _appRepository;

  RespondToRequestUseCase(this._appRepository);

  @override
  Future<void> call({required Request params}) async{
    await _appRepository.respondToRequest(params);
  }
}