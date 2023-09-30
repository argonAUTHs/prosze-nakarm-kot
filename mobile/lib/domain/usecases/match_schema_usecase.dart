import '../../core/usecases/future_usecase.dart';
import '../entities/acdc_db.dart';
import '../repositories/app_repository.dart';

class MatchSchemaUseCase implements FutureUseCase<List<AcdcDB>, String>{
  final AppRepository _appRepository;

  MatchSchemaUseCase(this._appRepository);

  @override
  Future<List<AcdcDB>> call({required String params}) async{
    return await _appRepository.matchSchema(params);
  }


}