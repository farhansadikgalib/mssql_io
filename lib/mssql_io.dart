/// MSSQL IO Plugin - Microsoft SQL Server access for Flutter
/// 
/// This plugin provides cross-platform SQL Server connectivity using
/// Dart FFI and FreeTDS. It supports queries, parameterized calls,
/// transactions, bulk insert, timeouts, auto-reconnect, and Base64
/// handling for binary columns.
/// 
/// Platforms: Windows, Android, iOS, macOS, Linux
/// 
/// Example usage:
/// ```dart
/// import 'package:mssql_io/mssql_io.dart';
/// 
/// // Get singleton instance
/// final request = MssqlConnection.getInstance();
/// 
/// // Connect to SQL Server
/// await request.connect(
///   host: '192.168.1.100',
///   port: 1433,
///   databaseName: 'MyDatabase',
///   username: 'sa',
///   password: 'MyPassword123',
///   timeoutInSeconds: 15,
/// );
/// 
/// // Execute queries
/// final result = await request.getData('SELECT * FROM Users');
/// for (final row in result.rows) {
///   print('User: ${row['Name']}');
/// }
/// 
/// // Parameterized queries (prevents SQL injection)
/// final users = await request.getDataWithParams(
///   'SELECT * FROM Users WHERE Age > @minAge',
///   [SqlParameter(name: 'minAge', value: 18)],
/// );
/// 
/// // Transactions
/// await request.beginTransaction();
/// try {
///   await request.writeData('INSERT INTO Users (Name) VALUES ("Alice")');
///   await request.writeData('UPDATE Stats SET UserCount = UserCount + 1');
///   await request.commit();
/// } catch (e) {
///   await request.rollback();
/// }
/// 
/// // Bulk insert
/// final rows = List.generate(1000, (i) => {'Name': 'User$i', 'Age': 20 + i});
/// await request.bulkInsert('Users', rows, batchSize: 500);
/// 
/// // Disconnect
/// await request.disconnect();
/// ```
library;

// Core connection
export 'src/mssql_connection.dart';

// Models
export 'src/models/connection_config.dart';
export 'src/models/query_result.dart';
export 'src/models/sql_parameter.dart';

// Exceptions
export 'src/exceptions/mssql_exceptions.dart';
