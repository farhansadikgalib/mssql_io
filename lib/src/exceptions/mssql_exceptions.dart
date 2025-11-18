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
  const ConnectionException(super.message, {super.details, super.errorCode});

  @override
  String toString() =>
      'ConnectionException: $message${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when authentication fails
class AuthenticationException extends MssqlException {
  const AuthenticationException(super.message,
      {super.details, super.errorCode});

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when query execution fails
class QueryException extends MssqlException {
  final String? query;

  const QueryException(super.message,
      {this.query, super.details, super.errorCode});

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
  const TransactionException(super.message, {super.details, super.errorCode});

  @override
  String toString() =>
      'TransactionException: $message${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when timeout occurs
class TimeoutException extends MssqlException {
  final int timeoutSeconds;

  const TimeoutException(super.message, this.timeoutSeconds, {super.details});

  @override
  String toString() =>
      'TimeoutException: $message (Timeout: ${timeoutSeconds}s)${details != null ? "\nDetails: $details" : ""}';
}

/// Exception thrown when native library cannot be loaded
class NativeLibraryException extends MssqlException {
  const NativeLibraryException(super.message, {super.details});

  @override
  String toString() =>
      'NativeLibraryException: $message${details != null ? "\nDetails: $details" : ""}';
}
