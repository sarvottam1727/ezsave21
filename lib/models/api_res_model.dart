class ApiResponse<T> {
  final T? data;
  final dynamic error;
  final Map<String, dynamic>? metadata;

  ApiResponse({this.data, this.error, this.metadata});

  bool get isSuccess => data != null;
}
