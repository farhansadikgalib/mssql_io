# Mobile Setup Guide

This guide helps you set up FreeTDS for Android and iOS.

## Prerequisites

### Android
- Android NDK (install via Android Studio SDK Manager)
- Set `ANDROID_NDK_HOME` environment variable, or ensure NDK is in `$ANDROID_HOME/ndk`

### iOS
- macOS (required for iOS development)
- Xcode with Command Line Tools
- CMake: `brew install cmake`

## Android Setup

1. **Navigate to Android directory**:
   ```bash
   cd android
   ```

2. **Make script executable**:
   ```bash
   chmod +x build_freetds.sh
   ```

3. **Run build script**:
   ```bash
   ./build_freetds.sh
   ```
   
   This will:
   - Download FreeTDS 1.3.18
   - Build for all Android ABIs (armeabi-v7a, arm64-v8a, x86, x86_64)
   - Install libraries to `src/main/jniLibs/`

4. **Verify build**:
   ```bash
   ls -la src/main/jniLibs/
   ```
   You should see directories for each ABI with `libsybdb.so` files.

5. **Rebuild Flutter app**:
   ```bash
   cd ..
   flutter clean
   flutter pub get
   flutter build apk
   ```

## iOS Setup

1. **Navigate to iOS directory**:
   ```bash
   cd ios
   ```

2. **Make script executable**:
   ```bash
   chmod +x build_freetds.sh
   ```

3. **Run build script**:
   ```bash
   ./build_freetds.sh
   ```
   
   This will:
   - Download FreeTDS 1.3.18
   - Build for device (arm64) and simulator (x86_64)
   - Create universal library `Frameworks/libsybdb.a`

4. **Install CocoaPods** (builds native library automatically):
   ```bash
   pod install
   ```
   
   This will:
   - Build the native `mssql_io` library
   - Link it with FreeTDS
   - Create `Frameworks/libmssql_io.a`

5. **Rebuild Flutter app**:
   ```bash
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

## Troubleshooting

### Android: "NDK not found"
- Install NDK via Android Studio: Tools → SDK Manager → SDK Tools → NDK
- Set `ANDROID_NDK_HOME` to your NDK path
- Or ensure NDK is in `$ANDROID_HOME/ndk`

### iOS: "cmake: command not found"
```bash
brew install cmake
```

### iOS: Build fails in pod install
- Ensure FreeTDS is built first: `./build_freetds.sh`
- Check that `Frameworks/libsybdb.a` exists
- Try: `pod deintegrate && pod install`

### Connection still fails
- Verify FreeTDS is built: Check for `libsybdb.so` (Android) or `libsybdb.a` (iOS)
- Check error message - it will tell you if stub is being used
- Rebuild: `flutter clean && flutter pub get && flutter run`

## Verification

After setup, try connecting to your SQL Server. If you see:
- ✅ Connection successful → FreeTDS is working!
- ❌ "FreeTDS not available" error → FreeTDS not linked, rebuild

