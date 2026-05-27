class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory ApiException.noInternet() =>
      const ApiException('No internet connection. Please check your network.');
  factory ApiException.timeout() =>
      const ApiException('Request timed out. Please try again.');

  factory ApiException.fromStatus(int code, String? serverMessage) {
    switch (code) {
      case 400:
        return ApiException(
          serverMessage ?? 'Invalid request',
          statusCode: code,
        );
      case 401:
        return ApiException(
          'Session expired. Please log in again.',
          statusCode: code,
        );
      case 403:
        return ApiException(
          'You don\'t have permission to do that.',
          statusCode: code,
        );
      case 404:
        return ApiException('Not found.', statusCode: code);
      case 422:
        return ApiException(
          serverMessage ?? 'Validation failed.',
          statusCode: code,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          'Server error. Please try again later.',
          statusCode: code,
        );
      default:
        return ApiException(serverMessage ?? 'Something went wrong.',statusCode: code);
    }
  }
}
