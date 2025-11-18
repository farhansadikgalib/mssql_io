import 'package:flutter_test/flutter_test.dart';
import 'package:mssql_io/mssql_io.dart';

void main() {
  group('MssqlException', () {
    test('creates with message', () {
      final exception = MssqlException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.details, isNull);
      expect(exception.errorCode, isNull);
    });

    test('creates with details and error code', () {
      final exception = MssqlException(
        'Test error',
        details: 'Additional info',
        errorCode: 500,
      );

      expect(exception.message, 'Test error');
      expect(exception.details, 'Additional info');
      expect(exception.errorCode, 500);
    });

    test('toString includes all information', () {
      final exception = MssqlException(
        'Test error',
        details: 'Details here',
        errorCode: 123,
      );

      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('Details here'));
      expect(str, contains('123'));
    });
  });

  group('ConnectionException', () {
    test('creates and formats correctly', () {
      final exception = ConnectionException(
        'Connection failed',
        details: 'Host unreachable',
      );

      expect(exception.message, 'Connection failed');
      expect(exception.toString(), contains('ConnectionException'));
      expect(exception.toString(), contains('Host unreachable'));
    });
  });

  group('AuthenticationException', () {
    test('creates and formats correctly', () {
      final exception = AuthenticationException('Auth failed');

      expect(exception.message, 'Auth failed');
      expect(exception.toString(), contains('AuthenticationException'));
    });
  });

  group('QueryException', () {
    test('creates with query', () {
      final exception = QueryException(
        'Query failed',
        query: 'SELECT * FROM Users',
      );

      expect(exception.message, 'Query failed');
      expect(exception.query, 'SELECT * FROM Users');
      expect(exception.toString(), contains('SELECT * FROM Users'));
    });

    test('creates without query', () {
      final exception = QueryException('Query failed');

      expect(exception.query, isNull);
    });
  });

  group('TransactionException', () {
    test('creates and formats correctly', () {
      final exception = TransactionException(
        'Transaction failed',
        details: 'Deadlock detected',
      );

      expect(exception.message, 'Transaction failed');
      expect(exception.toString(), contains('TransactionException'));
      expect(exception.toString(), contains('Deadlock detected'));
    });
  });

  group('TimeoutException', () {
    test('creates with timeout value', () {
      final exception = TimeoutException('Operation timed out', 30);

      expect(exception.message, 'Operation timed out');
      expect(exception.timeoutSeconds, 30);
      expect(exception.toString(), contains('30'));
    });
  });

  group('NativeLibraryException', () {
    test('creates and formats correctly', () {
      final exception = NativeLibraryException(
        'Failed to load library',
        details: 'File not found',
      );

      expect(exception.message, 'Failed to load library');
      expect(exception.toString(), contains('NativeLibraryException'));
      expect(exception.toString(), contains('File not found'));
    });
  });
}

