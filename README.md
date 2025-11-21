# MSSQL IO

Flutter plugin for Microsoft SQL Server. Works on Android, iOS, Windows, macOS, Linux, and Web.

## Installation

```yaml
dependencies:
  mssql_io: ^0.0.5
```

## Quick Setup

**The plugin will build without FreeTDS** (stub implementation), but you need FreeTDS for actual database connections.

### Android Setup

1. **Build FreeTDS for Android** (one-time, ~15-20 minutes):
   ```bash
   cd android
   chmod +x build_freetds.sh
   ./build_freetds.sh
   ```
   Requires: Android NDK (set `ANDROID_NDK_HOME` or install via Android Studio)

2. **Rebuild your app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

### iOS Setup

1. **Build FreeTDS for iOS** (one-time, ~10-15 minutes, macOS only):
   ```bash
   cd ios
   chmod +x build_freetds.sh
   ./build_freetds.sh
   ```
   Requires: Xcode, CMake (`brew install cmake`)

2. **Install pods** (builds native library automatically):
   ```bash
   cd ios
   pod install
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

### Desktop Setup

```bash
brew install freetds              # macOS
sudo apt-get install freetds-dev  # Linux
vcpkg install freetds:x64-windows # Windows
```

### Web Setup

Requires backend API proxy. See [Web Platform](#web-platform) section.

## Usage

```dart
import 'package:mssql_io/mssql_io.dart';

final request = MssqlConnection.getInstance();

// Connect
await request.connect(
  host: '192.168.1.100',
  databaseName: 'MyDB',
  username: 'sa',
  password: 'Password123',
);

// Query
final result = await request.getData('SELECT * FROM Users');

// Parameterized query (prevents SQL injection)
final users = await request.getDataWithParams(
  'SELECT * FROM Users WHERE Age > @age',
  [SqlParameter(name: 'age', value: 18)],
);

// Insert with parameters
await request.writeDataWithParams(
  'INSERT INTO Users (Name, Email) VALUES (@name, @email)',
  [SqlParameter(name: 'name', value: 'Alice'),
   SqlParameter(name: 'email', value: 'alice@example.com')],
);

// Transaction
await request.beginTransaction();
try {
  await request.writeData('INSERT INTO Orders VALUES (1, 99.99)');
  await request.commit();
} catch (e) {
  await request.rollback();
}

await request.disconnect();
```

## API

- `connect()` / `disconnect()` - Connection
- `getData()` / `getDataWithParams()` - Queries
- `writeData()` / `writeDataWithParams()` - Insert/Update/Delete
- `beginTransaction()` / `commit()` / `rollback()` - Transactions
- `bulkInsert()` - Batch operations

## Security

Always use parameterized queries:

```dart
// Safe
await request.getDataWithParams('SELECT * FROM Users WHERE Name = @name',
  [SqlParameter(name: 'name', value: userInput)]);

// Unsafe!
await request.getData("SELECT * FROM Users WHERE Name = '$userInput'");
```

## Troubleshooting

**Can't connect?**
- Check SQL Server is running on port 1433
- Test: `telnet your-server 1433`

**Library not found?**
- Mobile: Run `./build_freetds.sh` in android/ or ios/
- Desktop: Install FreeTDS


## Author

[Farhan Sadik Galib](https://farhansadikgalib.com/)

