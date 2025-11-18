# Release Notes - MSSQL IO v0.0.1

## 🎉 Initial Release

This is the first public release of MSSQL IO - a high-performance Flutter plugin for Microsoft SQL Server connectivity.

---

## What's Included

### ✅ Core Features
- Direct FFI access to SQL Server via FreeTDS
- Cross-platform support: Windows, Android, iOS, macOS, Linux
- Secure parameterized queries (SQL injection protection)
- Transaction management (BEGIN, COMMIT, ROLLBACK)
- Bulk insert operations
- Configurable timeouts and auto-reconnect
- Base64 encoding for binary columns
- Comprehensive error handling

### ✅ Platform Support
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **macOS**: 10.14+
- **Windows**: Windows 10+
- **Linux**: Ubuntu 20.04+, Fedora, Arch

### ✅ Mobile Ready
- Automated FreeTDS build scripts for Android and iOS
- NDK integration for Android
- CocoaPods integration for iOS
- Complete mobile setup documentation

### ✅ Documentation
- Comprehensive README with examples
- API reference with dartdoc
- Mobile setup guide
- Contributing guidelines
- Troubleshooting guide

### ✅ Testing
- Unit tests with mocked FFI
- Integration tests
- Example Flutter application

---

## Installation

```yaml
dependencies:
  mssql_io: ^0.0.1
```

## Quick Start

```dart
import 'package:mssql_io/mssql_io.dart';

final conn = MssqlConnection.getInstance();

await conn.connect(
  host: 'your-server',
  databaseName: 'YourDB',
  username: 'sa',
  password: 'YourPassword',
);

final result = await conn.getData('SELECT * FROM Users');
print('Found ${result.rowCount} users');

await conn.disconnect();
```

---

## Mobile Setup

### Android
```bash
cd android
./build_freetds.sh
cd ../example
flutter build apk
```

### iOS
```bash
cd ios
./build_freetds.sh
cd ../example
flutter build ios
```

---

## Package Validation

✅ **Package Size**: 39 KB (compressed)  
✅ **Warnings**: 0  
✅ **Pub.dev Ready**: Yes  
✅ **All Platforms Configured**: Yes

---

## Known Limitations

- FreeTDS must be built manually for Android/iOS (automated scripts provided)
- Windows Authentication not yet supported
- Connection pooling not yet implemented
- First build takes 15-20 minutes (FreeTDS compilation)

---

## Author

**Farhan Sadik Galib**  
Sr. Mobile Apps Developer | 5+ years experience

- 🌐 [farhansadikgalib.com](https://farhansadikgalib.com/)
- 💼 [GitHub](https://github.com/farhansadikgalib)
- 💼 [LinkedIn](https://www.linkedin.com/in/farhansadikgalib)
- 📍 Dhaka, Bangladesh
- 🏢 ACI Limited

---

## Links

- **Repository**: [github.com/farhansadikgalib/mssql_io](https://github.com/farhansadikgalib/mssql_io)
- **Package**: [pub.dev/packages/mssql_io](https://pub.dev/packages/mssql_io)
- **Documentation**: [pub.dev/documentation/mssql_io](https://pub.dev/documentation/mssql_io/latest/)
- **Issues**: [github.com/farhansadikgalib/mssql_io/issues](https://github.com/farhansadikgalib/mssql_io/issues)

---

## Next Steps

1. Test with your SQL Server
2. Report bugs or request features
3. Star the repository if you find it useful
4. Contribute improvements

---

**Released**: November 18, 2025  
**Version**: 0.0.1  
**License**: MIT

