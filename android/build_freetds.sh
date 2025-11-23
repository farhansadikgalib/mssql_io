#!/bin/bash
# Build FreeTDS for Android using NDK
# This script is automatically called by Gradle during build
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FREETDS_VERSION="1.3.18"
FREETDS_URL="https://www.freetds.org/files/stable/freetds-${FREETDS_VERSION}.tar.gz"

# Android NDK path
if [ -z "$ANDROID_NDK_HOME" ]; then
    if [ -z "$ANDROID_HOME" ]; then
        echo "Warning: ANDROID_HOME not set. Trying common locations..."
        if [ -d "$HOME/Library/Android/sdk" ]; then
            ANDROID_HOME="$HOME/Library/Android/sdk"
        elif [ -d "$HOME/Android/Sdk" ]; then
            ANDROID_HOME="$HOME/Android/Sdk"
        fi
    fi
    
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME/ndk" ]; then
        # Find the latest NDK version
        ANDROID_NDK_HOME=$(find "$ANDROID_HOME/ndk" -maxdepth 1 -type d | sort -V | tail -n 1)
    fi
fi

if [ -z "$ANDROID_NDK_HOME" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Error: Android NDK not found."
    echo "Please set ANDROID_NDK_HOME or install Android NDK via Android Studio:"
    echo "  Tools > SDK Manager > SDK Tools > NDK (Side by side)"
    echo ""
    echo "Then set: export ANDROID_NDK_HOME=\$ANDROID_HOME/ndk/[version]"
    exit 1
fi

echo "Using NDK: $ANDROID_NDK_HOME"

BUILD_DIR="$SCRIPT_DIR/freetds-build"
INSTALL_DIR="$SCRIPT_DIR/src/main/jniLibs"

# Android API level (21 = Android 5.0 minimum)
API_LEVEL=21

# ABIs to build for
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download FreeTDS if not already downloaded
if [ ! -f "freetds-${FREETDS_VERSION}.tar.gz" ]; then
    echo "Downloading FreeTDS ${FREETDS_VERSION}..."
    echo "URL: $FREETDS_URL"
    if ! curl -L -f -o "freetds-${FREETDS_VERSION}.tar.gz" "$FREETDS_URL"; then
        echo "Error: Failed to download FreeTDS"
        echo "Please check your internet connection and try again"
        exit 1
    fi
    echo "✓ Download complete"
fi

# Verify download
if [ ! -f "freetds-${FREETDS_VERSION}.tar.gz" ]; then
    echo "Error: FreeTDS archive not found after download"
    exit 1
fi

# Extract FreeTDS
if [ ! -d "freetds-${FREETDS_VERSION}" ]; then
    echo "Extracting FreeTDS..."
    if ! tar -xzf "freetds-${FREETDS_VERSION}.tar.gz"; then
        echo "Error: Failed to extract FreeTDS archive"
        exit 1
    fi
    echo "✓ Extraction complete"
fi

cd "freetds-${FREETDS_VERSION}"

# Build for each ABI
for ABI in "${ABIS[@]}"; do
    echo ""
    echo "========================================"
    echo "Building for $ABI"
    echo "========================================"
    
    # Set architecture-specific variables
    case $ABI in
        armeabi-v7a)
            ARCH="arm"
            TARGET="armv7a-linux-androideabi"
            ;;
        arm64-v8a)
            ARCH="arm64"
            TARGET="aarch64-linux-android"
            ;;
        x86)
            ARCH="x86"
            TARGET="i686-linux-android"
            ;;
        x86_64)
            ARCH="x86_64"
            TARGET="x86_64-linux-android"
            ;;
    esac
    
    # Setup toolchain
    TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
    if [ ! -d "$TOOLCHAIN" ]; then
        TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
    fi
    
    export CC="$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"
    
    # Create build directory for this ABI
    BUILD_ABI_DIR="$BUILD_DIR/build-$ABI"
    mkdir -p "$BUILD_ABI_DIR"
    cd "$BUILD_DIR/freetds-${FREETDS_VERSION}"
    
    # Configure
    echo "Configuring FreeTDS for $ABI..."
    if ! ./configure \
        --host=$TARGET \
        --prefix="$BUILD_ABI_DIR" \
        --enable-shared \
        --disable-static \
        --with-tdsver=7.4 \
        --disable-odbc \
        --disable-apps \
        --disable-server \
        --disable-pool \
        --disable-debug \
        CFLAGS="-O2 -fPIC" \
        LDFLAGS="-L$TOOLCHAIN/sysroot/usr/lib/$TARGET/$API_LEVEL"; then
        echo "Error: Configure failed for $ABI"
        exit 1
    fi
    
    # Build
    echo "Building FreeTDS for $ABI..."
    make clean || true
    if ! make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2); then
        echo "Error: Build failed for $ABI"
        exit 1
    fi
    
    if ! make install; then
        echo "Error: Install failed for $ABI"
        exit 1
    fi
    
    # Copy libraries and headers to jniLibs
    JNILIBS_DIR="$INSTALL_DIR/$ABI"
    mkdir -p "$JNILIBS_DIR"
    
    # Copy libraries
    if [ ! -f "$BUILD_ABI_DIR/lib/libsybdb.so" ] && [ ! -f "$BUILD_ABI_DIR/lib/libsybdb.so.5" ]; then
        echo "Error: Library not found for $ABI after build"
        exit 1
    fi
    cp "$BUILD_ABI_DIR/lib/libsybdb.so"* "$JNILIBS_DIR/" 2>/dev/null || {
        echo "Error: Failed to copy libraries for $ABI"
        exit 1
    }
    
    # Rename to canonical name
    if [ -f "$JNILIBS_DIR/libsybdb.so.5" ]; then
        cp "$JNILIBS_DIR/libsybdb.so.5" "$JNILIBS_DIR/libsybdb.so"
    fi
    
    # Verify library exists
    if [ ! -f "$JNILIBS_DIR/libsybdb.so" ]; then
        echo "Error: libsybdb.so not found for $ABI after copy"
        exit 1
    fi
    
    # Copy headers to include directory
    INCLUDE_DIR="$JNILIBS_DIR/include"
    mkdir -p "$INCLUDE_DIR"
    if [ -d "$BUILD_ABI_DIR/include" ]; then
        cp -r "$BUILD_ABI_DIR/include"/* "$INCLUDE_DIR/" 2>/dev/null || true
    fi
    # Also try copying from source if install didn't work
    if [ ! -f "$INCLUDE_DIR/sybdb.h" ]; then
        if [ -d "$BUILD_DIR/freetds-${FREETDS_VERSION}/include" ]; then
            cp -r "$BUILD_DIR/freetds-${FREETDS_VERSION}/include"/* "$INCLUDE_DIR/" 2>/dev/null || true
        fi
    fi
    
    # Verify headers
    if [ ! -f "$INCLUDE_DIR/sybdb.h" ]; then
        echo "Warning: sybdb.h not found for $ABI, but continuing..."
    fi
    
    echo "✓ Built and installed for $ABI"
done

echo ""
echo "========================================"
echo "FreeTDS build complete!"
echo "========================================"
echo "Libraries installed in: $INSTALL_DIR"
echo ""
echo "Contents:"
for ABI in "${ABIS[@]}"; do
    echo "  $ABI:"
    ls -lh "$INSTALL_DIR/$ABI/"
done

echo ""
echo "Next steps:"
echo "  1. Run: flutter clean"
echo "  2. Run: flutter pub get"
echo "  3. Run: flutter build apk"

