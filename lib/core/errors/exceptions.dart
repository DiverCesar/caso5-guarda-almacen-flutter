class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error de comunicación con el servidor']);

  @override
  String toString() => message;
}
