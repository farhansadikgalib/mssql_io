import 'package:flutter/material.dart';
import 'package:mssql_io/mssql_io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSSQL IO Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _hostController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '1433');
  final _databaseController = TextEditingController(text: 'TestDB');
  final _usernameController = TextEditingController(text: 'sa');
  final _passwordController = TextEditingController(text: 'Password123');
  
  final _queryController = TextEditingController(
    text: 'SELECT 1 AS num, \'Hello\' AS message',
  );
  
  final MssqlConnection _conn = MssqlConnection.getInstance();
  
  bool _isConnected = false;
  String _output = 'Not connected';
  bool _isLoading = false;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      _output = 'Connecting...';
    });

    try {
      await _conn.connect(
        host: _hostController.text,
        port: int.parse(_portController.text),
        databaseName: _databaseController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        timeoutInSeconds: 15,
      );

      setState(() {
        _isConnected = true;
        _output = 'Connected successfully to ${_databaseController.text}';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _output = 'Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await _conn.disconnect();
      setState(() {
        _isConnected = false;
        _output = 'Disconnected';
      });
    } catch (e) {
      setState(() {
        _output = 'Disconnect failed: $e';
      });
    }
  }

  Future<void> _executeQuery() async {
    if (!_isConnected) {
      setState(() {
        _output = 'Not connected. Please connect first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _output = 'Executing query...';
    });

    try {
      final result = await _conn.getData(_queryController.text);
      
      final buffer = StringBuffer();
      buffer.writeln('Query executed successfully\n');
      buffer.writeln('Columns: ${result.columns.join(", ")}\n');
      buffer.writeln('Rows returned: ${result.rowCount}\n');
      
      if (result.isNotEmpty) {
        buffer.writeln('Results:');
        for (int i = 0; i < result.rows.length; i++) {
          buffer.writeln('Row ${i + 1}: ${result.rows[i]}');
        }
      }

      setState(() {
        _output = buffer.toString();
      });
    } catch (e) {
      setState(() {
        _output = 'Query failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTransaction() async {
    if (!_isConnected) {
      setState(() {
        _output = 'Not connected. Please connect first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _output = 'Testing transaction...';
    });

    try {
      await _conn.beginTransaction();
      
      // Create a temporary table
      await _conn.writeData('''
        IF OBJECT_ID('TempTest', 'U') IS NOT NULL 
          DROP TABLE TempTest;
        CREATE TABLE TempTest (Id INT, Value NVARCHAR(50));
      ''');
      
      // Insert some data
      await _conn.writeData('INSERT INTO TempTest VALUES (1, \'Test1\')');
      await _conn.writeData('INSERT INTO TempTest VALUES (2, \'Test2\')');
      
      // Query the data
      final result = await _conn.getData('SELECT * FROM TempTest');
      
      // Rollback to clean up
      await _conn.rollback();

      setState(() {
        _output = 'Transaction test successful\n'
            'Created table, inserted ${result.rowCount} rows, '
            'then rolled back.\n\n'
            'Data during transaction:\n${result.rows}';
      });
    } catch (e) {
      try {
        await _conn.rollback();
      } catch (_) {}
      setState(() {
        _output = 'Transaction test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testParameterizedQuery() async {
    if (!_isConnected) {
      setState(() {
        _output = 'Not connected. Please connect first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _output = 'Testing parameterized query...';
    });

    try {
      final result = await _conn.getDataWithParams(
        'SELECT @name AS Name, @age AS Age, @active AS Active',
        [
          SqlParameter(name: 'name', value: 'John Doe'),
          SqlParameter(name: 'age', value: 30),
          SqlParameter(name: 'active', value: true),
        ],
      );

      setState(() {
        _output = 'Parameterized query successful\n\n'
            'Result: ${result.rows.first}';
      });
    } catch (e) {
      setState(() {
        _output = 'Parameterized query failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSSQL IO Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              color: _isConnected ? Colors.green[50] : Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.cancel,
                      color: _isConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Fields
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _databaseController,
              decoration: const InputDecoration(
                labelText: 'Database',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Connection Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _isConnected ? null : _connect,
                    icon: const Icon(Icons.link),
                    label: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_isConnected ? null : _disconnect,
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Query Section
            const Text(
              'Execute Query',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'SQL Query',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading || !_isConnected ? null : _executeQuery,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Execute Query'),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            const Text(
              'Test Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading || !_isConnected
                      ? null
                      : _testParameterizedQuery,
                  icon: const Icon(Icons.settings),
                  label: const Text('Parameterized Query'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _isLoading || !_isConnected ? null : _testTransaction,
                  icon: const Icon(Icons.sync),
                  label: const Text('Transaction'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Output Section
            const Text(
              'Output',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              constraints: const BoxConstraints(minHeight: 150),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        _output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
