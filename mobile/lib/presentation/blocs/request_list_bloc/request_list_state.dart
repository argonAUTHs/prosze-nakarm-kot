import '../../../domain/entities/request.dart';

abstract class RequestListState{
  final List<Request>? requestList;
  const RequestListState({this.requestList});
}

class RequestListInitial extends RequestListState{
  const RequestListInitial();
}

class RequestListLoading extends RequestListState{
  const RequestListLoading();
}

class RequestListDone extends RequestListState{
  const RequestListDone(List<Request> requestList) : super(requestList: requestList);
}

class RequestListError extends RequestListState{
  const RequestListError();
}