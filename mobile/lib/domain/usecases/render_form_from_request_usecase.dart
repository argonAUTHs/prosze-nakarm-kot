import 'package:oca_dart/widget_data.dart';

import '../../core/usecases/future_usecase.dart';
import '../entities/request.dart';
import '../repositories/app_repository.dart';

class RenderFormFromRequestUseCase implements FutureUseCase<WidgetData, Request>{
  final AppRepository _appRepository;

  RenderFormFromRequestUseCase(this._appRepository);

  @override
  Future<WidgetData> call({required Request params}) async{
    return await _appRepository.renderFormFromRequest(params);
  }

}