/// Base class for all domain-level exceptions in the app.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the server returns a non-2xx status code.
final class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

/// Thrown when the device has no internet connection.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// Thrown when the server returns 401 Unauthorized.
final class UnauthorisedException extends AppException {
  const UnauthorisedException(
      [super.message = 'Session expired. Please log in again.']);
}

/// Thrown when there is a problem parsing the response.
final class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse server response.']);
}

/// Thrown for any unknown / unexpected error.
final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
