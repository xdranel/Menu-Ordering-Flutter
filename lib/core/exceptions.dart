class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(
      {this.message = 'No internet connection or server unreachable'});

  @override
  String toString() => 'NetworkException: $message';
}
