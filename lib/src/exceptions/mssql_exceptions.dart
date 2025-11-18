/// Base exception for MSSQL plugin errors
class MssqlException implements Exception {
  final String message;
  final String? details;
  final int? errorCode;

  const MssqlException(this.message, {this.details, this.errorCode});

  @override
  String toString() {
    final buffer = StringBuffer('MssqlException: $message');
    if (errorCode != null) {
      buffer.write(' (Error code: $errorCode)');
    }
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}

/// Exception thrown when connection fails
class ConnectionException extends MssqlException {
  const ConnectionException(String message, {String? details, int? errorCode})
      : super(message, details: details, errorCode: errorCode);

  @override
  String toString() => 'ConnectionException: $message${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when authentication fails
class AuthenticationException extends MssqlException {
  const AuthenticationException(String message, {String? details, int? errorCode})
      : super(message, details: details, errorCode: errorCode);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when query execution fails
class QueryException extends MssqlException {
  final String? query;

  const QueryException(String message, {this.query, String? details, int? errorCode})
      : super(message, details: details, errorCode: errorCode);

  @override
  String toString() {
    final buffer = StringBuffer('QueryException: $message');
    if (query != null) {
      buffer.write('\nQuery: $query');
    }
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}

/// Exception thrown when transaction operation fails
class TransactionException extends MssqlException {
  const TransactionException(String message, {String? details, int? errorCode})
      : super(message, details: details, errorCode: errorCode);

  @override
  String toString() => 'TransactionException: $message${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when timeout occurs
class TimeoutException extends MssqlException {
  final int timeoutSeconds;

  const TimeoutException(String message, this.timeoutSeconds, {String? details})
      : super(message, details: details);

  @override
  String toString() =>
      'TimeoutException: $message (Timeout: ${timeoutSeconds}s)${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when native library cannot be loaded
class NativeLibraryException extends MssqlException {
  const NativeLibraryException(String message, {String? details})
      : super(message, details: details);

  @override
  String toString() => 'NativeLibraryException: $message${details != null ? "\nDetails: $details" : ""}';
}

