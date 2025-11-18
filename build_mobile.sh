#!/bin/bash
# Unified build script for Android and iOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "MSSQL IO Mobile Build Script"
echo "================================================"
echo ""

# Check platform
PLATFORM=""
if [ "$1" = "android" ] || [ "$1" = "ios" ] || [ "$1" = "both" ]; then
    PLATFORM="$1"
else
    echo "Usage: ./build_mobile.sh [android|ios|both]"
    echo ""
    echo "Examples:"
    echo "  ./build_mobile.sh android    # Build for Android only"
    echo "  ./build_mobile.sh ios        # Build for iOS only (macOS required)"
    echo "  ./build_mobile.sh both       # Build for both platforms"
    exit 1
fi

build_android() {
    echo ""
    echo "Building for Android..."
    echo "======================="
    
    if [ ! -d "$SCRIPT_DIR/android/src/main/jniLibs" ] || [ -z "$(ls -A $SCRIPT_DIR/android/src/main/jniLibs 2>/dev/null)" ]; then
        echo "FreeTDS not found for Android. Building..."
        cd "$SCRIPT_DIR/android"
        ./build_freetds.sh
    else
        echo "✓ FreeTDS already built for Android"
    fi
    
    echo ""
    echo "Building example APK..."
    cd "$SCRIPT_DIR/example"
    flutter clean
    flutter pub get
    flutter build apk --debug
    
    echo ""
    echo "✓ Android build complete!"
    echo "APK: $SCRIPT_DIR/example/build/app/outputs/flutter-apk/app-debug.apk"
}

build_ios() {
    echo ""
    echo "Building for iOS..."
    echo "==================="
    
    # Check if on macOS
    if [ "$(uname)" != "Darwin" ]; then
        echo "Error: iOS build requires macOS"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/ios/Frameworks/libsybdb.a" ]; then
        echo "FreeTDS not found for iOS. Building..."
        cd "$SCRIPT_DIR/ios"
        ./build_freetds.sh
    else
        echo "✓ FreeTDS already built for iOS"
    fi
    
    echo ""
    echo "Installing CocoaPods..."
    cd "$SCRIPT_DIR/example/ios"
    pod install
    
    echo ""
    echo "Building iOS app..."
    cd "$SCRIPT_DIR/example"
    flutter clean
    flutter pub get
    flutter build ios --debug --no-codesign
    
    echo ""
    echo "✓ iOS build complete!"
    echo "App: $SCRIPT_DIR/example/build/ios/Debug-iphoneos/Runner.app"
}

# Execute builds
case $PLATFORM in
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    both)
        build_android
        build_ios
        ;;
esac

echo ""
echo "================================================"
echo "✓ Build Complete!"
echo "================================================"
echo ""
echo "To run on a device:"
echo "  flutter devices                    # List devices"
echo "  flutter run -d <device-id>        # Run on device"
echo ""
echo "For more information, see MOBILE_SETUP.md"

