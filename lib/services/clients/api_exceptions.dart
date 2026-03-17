/// Base exception for all API errors
class ApiException implements Exception {
  final int? statusCode;
  final String? body;
  final String message;

  ApiException({this.statusCode, this.body, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when an HTTP request times out
class ApiTimeoutException extends ApiException {
  ApiTimeoutException({String? message})
      : super(message: message ?? 'Request timed out');
}

/// Thrown when there is no network connectivity or a socket error occurs
class ApiNetworkException extends ApiException {
  ApiNetworkException({String? message})
      : super(message: message ?? 'No network connection');
}

/// Thrown when the server returns 401 Unauthorized
class ApiUnauthorizedException extends ApiException {
  ApiUnauthorizedException({String? body})
      : super(statusCode: 401, body: body, message: 'Unauthorized');
}
