abstract class PostAcdcToAuthorizeState{
  final String? response;

  const PostAcdcToAuthorizeState({this.response});
}

class PostAcdcToAuthorizeInitial extends PostAcdcToAuthorizeState{
  const PostAcdcToAuthorizeInitial();
}

class PostAcdcToAuthorizeLoading extends PostAcdcToAuthorizeState{
  const PostAcdcToAuthorizeLoading();
}

class PostAcdcToAuthorizeDone extends PostAcdcToAuthorizeState{
  const PostAcdcToAuthorizeDone(String response):super(response: response);
}

class PostAcdcToAuthorizeError extends PostAcdcToAuthorizeState{
  const PostAcdcToAuthorizeError();
}