# MSSQL IO

A Flutter plugin for connecting to Microsoft SQL Server. Supports Android, iOS, Windows, macOS, and Linux.

## Features

- Direct FFI access for high performance
- Parameterized queries to prevent SQL injection
- Transaction support (BEGIN, COMMIT, ROLLBACK)
- Bulk insert operations
- Cross-platform compatibility

## Installation

```yaml
dependencies:
  mssql_io: ^0.0.2
```

```bash
flutter pub get
```

## Setup

### Mobile (Android & iOS)

Run the automated build script:

```bash
# Android
cd android && ./build_freetds.sh

# iOS (requires macOS)
cd ios && ./build_freetds.sh
```

First build takes 15-20 minutes (builds FreeTDS library). Subsequent builds are fast.

### Desktop

**macOS:**
```bash
brew install freetds
```

**Linux:**
```bash
sudo apt-get install freetds-dev
```

**Windows:**
```bash
vcpkg install freetds:x64-windows
```

## Usage

```dart
import 'package:mssql_io/mssql_io.dart';

// Connect
final request = MssqlConnection.getInstance();
await request.connect(
  host: '192.168.1.100',
  databaseName: 'MyDB',
  username: 'sa',
  password: 'Password123',
);

// Query
final result = await request.getData('SELECT * FROM Users');
for (final row in result.rows) {
  print('User: ${row['Name']}');
}

// Disconnect
await request.disconnect();
```

## Common Examples

### Parameterized Queries (Prevents SQL Injection)

```dart
final result = await request.getDataWithParams(
  'SELECT * FROM Users WHERE Age > @age',
  [SqlParameter(name: 'age', value: 18)],
);
```

### Insert/Update/Delete

```dart
final rows = await request.writeDataWithParams(
  'INSERT INTO Users (Name, Email) VALUES (@name, @email)',
  [
    SqlParameter(name: 'name', value: 'Alice'),
    SqlParameter(name: 'email', value: 'alice@example.com'),
  ],
);
print('Inserted $rows rows');
```

### Transactions

```dart
await request.beginTransaction();
try {
  await request.writeData('INSERT INTO Orders VALUES (1, 99.99)');
  await request.writeData('UPDATE Inventory SET Stock = Stock - 1');
  await request.commit();
} catch (e) {
  await request.rollback();
}
```

### Bulk Insert

```dart
final rows = List.generate(1000, (i) => {'Name': 'User$i', 'Age': 20 + i});
await request.bulkInsert('Users', rows, batchSize: 500);
```

## API

**Main Methods:**
- `connect()` - Connect to SQL Server
- `getData()` - Execute SELECT query
- `getDataWithParams()` - Secure parameterized query
- `writeData()` - Execute INSERT/UPDATE/DELETE
- `writeDataWithParams()` - Secure parameterized write
- `beginTransaction()`, `commit()`, `rollback()` - Transactions
- `bulkInsert()` - Batch insert rows
- `disconnect()` - Close connection

**Result Object:**
```dart
QueryResult {
  columns: ['Id', 'Name', 'Age'],
  rows: [{'Id': 1, 'Name': 'Alice', 'Age': 25}],
  affectedRows: 0
}
```

## Security

**Always use parameterized queries** to prevent SQL injection:

```dart
// Good - Safe
await request.getDataWithParams(
  'SELECT * FROM Users WHERE Name = @name',
  [SqlParameter(name: 'name', value: userInput)],
);

// Bad - SQL Injection Risk!
await request.getData("SELECT * FROM Users WHERE Name = '$userInput'");
```

## Troubleshooting

**Can't connect?**
- Check SQL Server is running on port 1433
- Verify firewall allows connections
- Test: `telnet your-server 1433`

**Library not found?**
- Run `./build_freetds.sh` in android/ or ios/ folder
- Desktop: Install FreeTDS (`brew install freetds` on macOS)

**Build errors?**
```bash
flutter clean
flutter pub get
flutter build apk  # or ios
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed troubleshooting.

## Documentation

- [API Documentation](https://pub.dev/documentation/mssql_io/latest/)
- [Example App](example/)
- [Report Issues](https://github.com/farhansadikgalib/mssql_io/issues)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## Author

Farhan Sadik Galib - [farhansadikgalib.com](https://farhansadikgalib.com/)

## License

MIT License - see [LICENSE](LICENSE) file
