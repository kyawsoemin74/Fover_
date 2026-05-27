class ApiResult<T> {
  const ApiResult._({this.data, this.error, this.stackTrace});

  final T? data;
  final String? error;
  final StackTrace? stackTrace;

  bool get isSuccess => error == null;

  factory ApiResult.success(T data) => ApiResult._(data: data);

  factory ApiResult.failure(String error, [StackTrace? stackTrace]) => ApiResult._(
        error: error,
        stackTrace: stackTrace,
      );
}
