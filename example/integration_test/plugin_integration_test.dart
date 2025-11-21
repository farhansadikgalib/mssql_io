import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mssql_io/mssql_io.dart';

/// Integration tests for MSSQL IO plugin
///
/// These tests require a running SQL Server instance.
/// Set environment variables or modify the connection config below.
///
/// To run:
/// flutter test integration_test/plugin_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Configure your test SQL Server connection here
  // Or use environment variables: MSSQL_HOST, MSSQL_PORT, etc.
  const testConfig = ConnectionConfig(
    host: 'localhost', // or use const String.fromEnvironment('MSSQL_HOST')
    port: 1433,
    databaseName: 'TestDatabase',
    username: 'sa',
    password: 'YourPassword123',
    timeoutInSeconds: 15,
  );

  // Skip all tests if no test server is configured
  // To run these tests, set skipIntegrationTests = false
  const skipIntegrationTests = true;

  group('MSSQL Connection Integration Tests', () {
    late MssqlConnection request;

    setUp(() {
      request = MssqlConnection.getInstance();
    });

    tearDown(() async {
      if (request.isConnected) {
        await request.disconnect();
      }
    });

    test('Connect to SQL Server', () async {
      final connected = await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
        timeoutInSeconds: testConfig.timeoutInSeconds,
      );

      expect(connected, true);
      expect(request.isConnected, true);
    }, skip: skipIntegrationTests);

    test('Execute simple SELECT query', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      final result = await request.getData('SELECT 1 AS num, \'test\' AS str');

      expect(result.columns, contains('num'));
      expect(result.columns, contains('str'));
      expect(result.rows.length, 1);
      expect(result.rows[0]['num'], 1);
      expect(result.rows[0]['str'], 'test');
    }, skip: skipIntegrationTests);

    test('Execute parameterized query', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      final result = await request.getDataWithParams(
        'SELECT @value AS result',
        [SqlParameter(name: 'value', value: 42)],
      );

      expect(result.rows.length, 1);
      expect(result.rows[0]['result'], 42);
    }, skip: skipIntegrationTests);

    test('Create table, insert, query, and drop', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      // Create test table
      await request.writeData('''
        IF OBJECT_ID('TestUsers', 'U') IS NOT NULL 
          DROP TABLE TestUsers;
        CREATE TABLE TestUsers (
          Id INT PRIMARY KEY IDENTITY(1,1),
          Name NVARCHAR(100),
          Age INT
        );
      ''');

      // Insert data
      final inserted = await request.writeDataWithParams(
        'INSERT INTO TestUsers (Name, Age) VALUES (@name, @age)',
        [
          SqlParameter(name: 'name', value: 'Alice'),
          SqlParameter(name: 'age', value: 25),
        ],
      );
      expect(inserted, 1);

      // Query data
      final result = await request.getData('SELECT * FROM TestUsers');
      expect(result.rows.length, 1);
      expect(result.rows[0]['Name'], 'Alice');
      expect(result.rows[0]['Age'], 25);

      // Clean up
      await request.writeData('DROP TABLE TestUsers');
    }, skip: skipIntegrationTests);

    test('Transaction commit', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      // Setup
      await request.writeData('''
        IF OBJECT_ID('TestCounter', 'U') IS NOT NULL 
          DROP TABLE TestCounter;
        CREATE TABLE TestCounter (Value INT);
        INSERT INTO TestCounter VALUES (0);
      ''');

      // Transaction
      await request.beginTransaction();
      await request.writeData('UPDATE TestCounter SET Value = 10');
      await request.commit();

      // Verify
      final result = await request.getData('SELECT Value FROM TestCounter');
      expect(result.rows[0]['Value'], 10);

      // Cleanup
      await request.writeData('DROP TABLE TestCounter');
    }, skip: skipIntegrationTests);

    test('Transaction rollback', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      // Setup
      await request.writeData('''
        IF OBJECT_ID('TestCounter', 'U') IS NOT NULL 
          DROP TABLE TestCounter;
        CREATE TABLE TestCounter (Value INT);
        INSERT INTO TestCounter VALUES (0);
      ''');

      // Transaction with rollback
      await request.beginTransaction();
      await request.writeData('UPDATE TestCounter SET Value = 99');
      await request.rollback();

      // Verify value unchanged
      final result = await request.getData('SELECT Value FROM TestCounter');
      expect(result.rows[0]['Value'], 0);

      // Cleanup
      await request.writeData('DROP TABLE TestCounter');
    }, skip: skipIntegrationTests);

    test('Bulk insert', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      // Setup table
      await request.writeData('''
        IF OBJECT_ID('BulkTest', 'U') IS NOT NULL 
          DROP TABLE BulkTest;
        CREATE TABLE BulkTest (
          Id INT,
          Name NVARCHAR(50)
        );
      ''');

      // Bulk insert
      final rows = List.generate(100, (i) => {'Id': i, 'Name': 'User$i'});

      final inserted = await request.bulkInsert(
        'BulkTest',
        rows,
        batchSize: 50,
      );
      expect(inserted, greaterThan(0));

      // Verify
      final result = await request.getData(
        'SELECT COUNT(*) AS cnt FROM BulkTest',
      );
      expect(result.rows[0]['cnt'], greaterThan(0));

      // Cleanup
      await request.writeData('DROP TABLE BulkTest');
    }, skip: skipIntegrationTests);

    test('Handle null values', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      final result = await request.getData('SELECT NULL AS nullval');

      expect(result.rows.length, 1);
      expect(result.rows[0]['nullval'], isNull);
    }, skip: skipIntegrationTests);

    test('Handle multiple result rows', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      final result = await request.getData('''
        SELECT 1 AS num UNION ALL
        SELECT 2 UNION ALL
        SELECT 3
      ''');

      expect(result.rows.length, 3);
      expect(result.rows[0]['num'], 1);
      expect(result.rows[1]['num'], 2);
      expect(result.rows[2]['num'], 3);
    }, skip: skipIntegrationTests);

    test('Connection timeout', () async {
      // Try to connect to unreachable host with short timeout
      try {
        await request.connect(
          host: '192.0.2.1', // TEST-NET-1 (unreachable)
          port: 1433,
          databaseName: 'TestDB',
          username: 'sa',
          password: 'pass',
          timeoutInSeconds: 2,
        );
        fail('Should have thrown timeout exception');
      } catch (e) {
        expect(e, isA<ConnectionException>());
      }
    }, skip: skipIntegrationTests);

    test('Disconnect and reconnect', () async {
      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      await request.disconnect();
      expect(request.isConnected, false);

      await request.connect(
        host: testConfig.host,
        port: testConfig.port,
        databaseName: testConfig.databaseName,
        username: testConfig.username,
        password: testConfig.password,
      );

      expect(request.isConnected, true);
    }, skip: skipIntegrationTests);
  });
}
