import '../../core/usecases/future_usecase.dart';
import '../entities/request.dart';
import '../repositories/app_repository.dart';

class GetRequestListUseCase implements FutureUseCase<List<Request>, void>{
  final AppRepository _appRepository;
  GetRequestListUseCase(this._appRepository);

  @override
  Future<List<Request>> call({void params}) async{
    return await _appRepository.getRequestList();
  }

}