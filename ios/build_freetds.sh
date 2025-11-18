#!/bin/bash
# Build FreeTDS for iOS (device and simulator)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FREETDS_VERSION="1.3.18"
FREETDS_URL="https://www.freetds.org/files/stable/freetds-${FREETDS_VERSION}.tar.gz"

BUILD_DIR="$SCRIPT_DIR/freetds-build"
FRAMEWORKS_DIR="$SCRIPT_DIR/Frameworks"

# iOS deployment target
IOS_DEPLOYMENT_TARGET="12.0"

echo "Building FreeTDS for iOS"
echo "========================="

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$FRAMEWORKS_DIR"
cd "$BUILD_DIR"

# Download FreeTDS
if [ ! -f "freetds-${FREETDS_VERSION}.tar.gz" ]; then
    echo "Downloading FreeTDS ${FREETDS_VERSION}..."
    curl -L -o "freetds-${FREETDS_VERSION}.tar.gz" "$FREETDS_URL"
fi

# Extract
if [ ! -d "freetds-${FREETDS_VERSION}" ]; then
    echo "Extracting FreeTDS..."
    tar -xzf "freetds-${FREETDS_VERSION}.tar.gz"
fi

cd "freetds-${FREETDS_VERSION}"

# Architectures to build
ARCHS=("arm64" "x86_64")
PLATFORMS=("iphoneos" "iphonesimulator")

# Build for each architecture
for i in "${!ARCHS[@]}"; do
    ARCH="${ARCHS[$i]}"
    PLATFORM="${PLATFORMS[$i]}"
    
    echo ""
    echo "========================================"
    echo "Building for $ARCH ($PLATFORM)"
    echo "========================================"
    
    # Set SDK
    if [ "$PLATFORM" = "iphoneos" ]; then
        SDK="iphoneos"
        HOST="arm-apple-darwin"
    else
        SDK="iphonesimulator"
        HOST="x86_64-apple-darwin"
    fi
    
    SDK_PATH=$(xcrun --sdk $SDK --show-sdk-path)
    BUILD_ARCH_DIR="$BUILD_DIR/build-$ARCH"
    
    # Configure flags
    export CC="$(xcrun --sdk $SDK --find clang)"
    export CXX="$(xcrun --sdk $SDK --find clang++)"
    export CFLAGS="-arch $ARCH -isysroot $SDK_PATH -mios-version-min=$IOS_DEPLOYMENT_TARGET -fembed-bitcode -O2"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-arch $ARCH -isysroot $SDK_PATH -mios-version-min=$IOS_DEPLOYMENT_TARGET"
    
    # Configure
    ./configure \
        --host=$HOST \
        --prefix="$BUILD_ARCH_DIR" \
        --enable-static \
        --disable-shared \
        --with-tdsver=7.4 \
        --disable-odbc \
        --disable-apps \
        --disable-server \
        --disable-pool \
        --disable-debug
    
    # Build
    make clean
    make -j$(sysctl -n hw.ncpu)
    make install
    
    echo "✓ Built for $ARCH"
done

echo ""
echo "========================================"
echo "Creating universal static library"
echo "========================================"

# Create universal (fat) library
DEVICE_LIB="$BUILD_DIR/build-arm64/lib/libsybdb.a"
SIMULATOR_LIB="$BUILD_DIR/build-x86_64/lib/libsybdb.a"
UNIVERSAL_LIB="$FRAMEWORKS_DIR/libsybdb.a"

if [ -f "$DEVICE_LIB" ] && [ -f "$SIMULATOR_LIB" ]; then
    lipo -create "$DEVICE_LIB" "$SIMULATOR_LIB" -output "$UNIVERSAL_LIB"
    echo "✓ Created universal library: $UNIVERSAL_LIB"
    
    # Show info
    echo ""
    echo "Library info:"
    lipo -info "$UNIVERSAL_LIB"
    ls -lh "$UNIVERSAL_LIB"
else
    echo "Error: Could not find built libraries"
    exit 1
fi

# Copy headers
HEADERS_DIR="$FRAMEWORKS_DIR/Headers"
mkdir -p "$HEADERS_DIR"
cp "$BUILD_DIR/build-arm64/include"/*.h "$HEADERS_DIR/" 2>/dev/null || true
echo "✓ Copied headers to $HEADERS_DIR"

echo ""
echo "========================================"
echo "FreeTDS build complete!"
echo "========================================"
echo ""
echo "Output:"
echo "  Library: $UNIVERSAL_LIB"
echo "  Headers: $HEADERS_DIR"
echo ""
echo "Next steps:"
echo "  1. Run: cd ios && pod install"
echo "  2. Run: flutter clean"
echo "  3. Run: flutter build ios"

