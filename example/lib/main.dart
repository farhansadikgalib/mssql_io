import 'package:flutter/material.dart';
import 'package:mssql_io/mssql_io.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSSQL IO Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
  final _request = MssqlConnection.getInstance();

  final _hostCtrl = TextEditingController(text: 'localhost');
  final _portCtrl = TextEditingController(text: '1433');
  final _dbCtrl = TextEditingController(text: 'TestDB');
  final _userCtrl = TextEditingController(text: 'sa');
  final _passCtrl = TextEditingController(text: 'Password123');
  final _queryCtrl = TextEditingController(
    text: 'SELECT 1 AS num, \'Hello\' AS msg',
  );

  bool _connected = false;
  String _output = 'Ready to connect';
  bool _loading = false;

  @override
  void dispose() {
    [
      _hostCtrl,
      _portCtrl,
      _dbCtrl,
      _userCtrl,
      _passCtrl,
      _queryCtrl,
    ].forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() => _loading = true);
    try {
      await _request.connect(
        host: _hostCtrl.text,
        port: int.parse(_portCtrl.text),
        databaseName: _dbCtrl.text,
        username: _userCtrl.text,
        password: _passCtrl.text,
      );
      setState(() {
        _connected = true;
        _output = 'Connected to ${_dbCtrl.text}';
      });
    } catch (e) {
      setState(() {
        _connected = false;
        _output = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _disconnect() async {
    await _request.disconnect();
    setState(() {
      _connected = false;
      _output = 'Disconnected';
    });
  }

  Future<void> _executeQuery() async {
    if (!_connected) return setState(() => _output = 'Not connected');

    setState(() => _loading = true);
    try {
      final result = await _request.getData(_queryCtrl.text);
      setState(
        () => _output = 'Success!\n'
            'Columns: ${result.columns.join(", ")}\n'
            'Rows: ${result.rowCount}\n\n'
            '${result.rows.take(10).join("\n")}',
      );
    } catch (e) {
      setState(() => _output = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testTransaction() async {
    if (!_connected) return setState(() => _output = 'Not connected');

    setState(() => _loading = true);
    try {
      await _request.beginTransaction();
      await _request.writeData('''
        IF OBJECT_ID('TempTest', 'U') IS NOT NULL DROP TABLE TempTest;
        CREATE TABLE TempTest (Id INT, Value NVARCHAR(50));
      ''');
      await _request.writeData(
        'INSERT INTO TempTest VALUES (1, \'Test1\'), (2, \'Test2\')',
      );
      final result = await _request.getData('SELECT * FROM TempTest');
      await _request.rollback();

      setState(
        () => _output = 'Transaction Success!\n'
            'Inserted ${result.rowCount} rows, then rolled back\n\n${result.rows}',
      );
    } catch (e) {
      try {
        await _request.rollback();
      } catch (_) {}
      setState(() => _output = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testParams() async {
    if (!_connected) return setState(() => _output = 'Not connected');

    setState(() => _loading = true);
    try {
      final result = await _request.getDataWithParams(
        'SELECT @name AS Name, @age AS Age',
        [
          SqlParameter(name: 'name', value: 'John'),
          SqlParameter(name: 'age', value: 25),
        ],
      );
      setState(
        () => _output = 'Parameterized Query Success!\n\n${result.rows.first}',
      );
    } catch (e) {
      setState(() => _output = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSSQL IO Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                _connected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: _connected ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField('Host', _hostCtrl),
                  _buildField('Port', _portCtrl),
                  _buildField('Database', _dbCtrl),
                  _buildField('Username', _userCtrl),
                  _buildField('Password', _passCtrl, obscure: true),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _connected ? null : _connect,
                          child: const Text('Connect'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !_connected ? null : _disconnect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Disconnect'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _queryCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'SQL Query',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: !_connected ? null : _executeQuery,
                    child: const Text('Execute Query'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: !_connected ? null : _testParams,
                        child: const Text('Test Params'),
                      ),
                      ElevatedButton(
                        onPressed: !_connected ? null : _testTransaction,
                        child: const Text('Test Transaction'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Output:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 100,
                      maxHeight: 400,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _output,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
