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
/// final conn = MssqlConnection.getInstance();
/// 
/// // Connect to SQL Server
/// await conn.connect(
///   host: '192.168.1.100',
///   port: 1433,
///   databaseName: 'MyDatabase',
///   username: 'sa',
///   password: 'MyPassword123',
///   timeoutInSeconds: 15,
/// );
/// 
/// // Execute queries
/// final result = await conn.getData('SELECT * FROM Users');
/// for (final row in result.rows) {
///   print('User: ${row['Name']}');
/// }
/// 
/// // Parameterized queries (prevents SQL injection)
/// final users = await conn.getDataWithParams(
///   'SELECT * FROM Users WHERE Age > @minAge',
///   [SqlParameter(name: 'minAge', value: 18)],
/// );
/// 
/// // Transactions
/// await conn.beginTransaction();
/// try {
///   await conn.writeData('INSERT INTO Users (Name) VALUES ("Alice")');
///   await conn.writeData('UPDATE Stats SET UserCount = UserCount + 1');
///   await conn.commit();
/// } catch (e) {
///   await conn.rollback();
/// }
/// 
/// // Bulk insert
/// final rows = List.generate(1000, (i) => {'Name': 'User$i', 'Age': 20 + i});
/// await conn.bulkInsert('Users', rows, batchSize: 500);
/// 
/// // Disconnect
/// await conn.disconnect();
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
