import 'package:oca_dart/widget_data.dart';

import '../../core/usecases/future_usecase.dart';
import '../entities/acdc_db.dart';
import '../repositories/app_repository.dart';

class SubmitFormUseCase implements FutureUseCase<AcdcDB, WidgetData>{
  final AppRepository _appRepository;
  SubmitFormUseCase(this._appRepository);

  @override
  Future<AcdcDB> call({required WidgetData params}) async{
    return await _appRepository.submitForm(params);
  }

}