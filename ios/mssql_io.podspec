Pod::Spec.new do |s|
  s.name             = 'mssql_io'
  s.version          = '0.0.5'
  s.summary          = 'Microsoft SQL Server plugin for Flutter using FreeTDS'
  s.description      = <<-DESC
A Flutter plugin that provides Microsoft SQL Server access using Dart FFI and FreeTDS.
Supports queries, transactions, bulk insert, and more.
                       DESC
  s.homepage         = 'https://farhansadikgalib.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Farhan Sadik Galib' => 'farhansadikgalib@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-framework Flutter'
  }

  # Vendored libraries (FreeTDS + our native lib)
  s.vendored_libraries = 'Frameworks/libsybdb.a', 'Frameworks/libmssql_io.a'
  
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_TARGET_SRCROOT}/Frameworks/Headers ${PODS_TARGET_SRCROOT}/../src',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) ${PODS_TARGET_SRCROOT}/Frameworks',
    'OTHER_LDFLAGS' => '-lc++'
  }

  s.swift_version = '5.0'
  
  # Script to build FreeTDS and native library
  s.prepare_command = <<-CMD
    echo "=========================================="
    echo "Preparing MSSQL IO native libraries for iOS"
    echo "=========================================="
    
    # Ensure script is executable
    chmod +x build_freetds.sh 2>/dev/null || true
    
    # Build FreeTDS if not already built
    FREETDS_BUILT=false
    if [ ! -f "Frameworks/libsybdb.a" ]; then
      echo ""
      echo "Building FreeTDS for iOS..."
      echo "This may take 10-15 minutes on first build."
      echo ""
      
      # Check prerequisites
      if ! command -v xcrun &> /dev/null; then
        echo "WARNING: xcrun not found. Xcode Command Line Tools required."
        echo "Install with: xcode-select --install"
        echo "Plugin will use stub implementation."
      else
        # Run FreeTDS build script
        if bash build_freetds.sh 2>&1; then
          if [ -f "Frameworks/libsybdb.a" ]; then
            echo "✓ FreeTDS built successfully"
            FREETDS_BUILT=true
          else
            echo "WARNING: FreeTDS build completed but library not found."
            echo "Plugin will use stub implementation."
          fi
        else
          echo "WARNING: FreeTDS build failed. Plugin will use stub implementation."
          echo "You can manually build FreeTDS later by running: cd ios && ./build_freetds.sh"
        fi
      fi
    else
      echo "✓ FreeTDS already built"
      FREETDS_BUILT=true
    fi
    
    # Build our native library
    if [ ! -f "Frameworks/libmssql_io.a" ]; then
      echo ""
      echo "Building mssql_io native library..."
      
      # Check if cmake is available
      if ! command -v cmake &> /dev/null; then
        echo "WARNING: cmake not found. Install with: brew install cmake"
        echo "Plugin will use stub implementation."
        exit 0
      fi
      
      # Check if FreeTDS is available
      if [ ! -f "Frameworks/libsybdb.a" ]; then
        echo "WARNING: FreeTDS not found. Building stub implementation."
        # We'll let CMake handle the stub build
      fi
      
      mkdir -p build
      cd build
      
      # Build for device (arm64) - static library
      mkdir -p device
      cd device
      if [ "$FREETDS_BUILT" = "true" ] && [ -f "../../Frameworks/libsybdb.a" ]; then
        echo "Building with FreeTDS support for device (arm64)..."
        cmake ../../../src \
          -DCMAKE_SYSTEM_NAME=iOS \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
          -DCMAKE_OSX_ARCHITECTURES=arm64 \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF \
          -DFREETDS_INCLUDE_DIR="${PWD}/../../Frameworks/Headers" \
          -DFREETDS_LIBRARY="${PWD}/../../Frameworks/libsybdb.a" || {
          echo "WARNING: CMake with FreeTDS failed, building stub..."
          cmake ../../../src \
            -DCMAKE_SYSTEM_NAME=iOS \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
            -DCMAKE_OSX_ARCHITECTURES=arm64 \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_SHARED_LIBS=OFF
        }
      else
        echo "Building stub implementation for device (arm64)..."
        cmake ../../../src \
          -DCMAKE_SYSTEM_NAME=iOS \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
          -DCMAKE_OSX_ARCHITECTURES=arm64 \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF
      fi
      
      make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 2) || {
        echo "WARNING: Device build failed"
        cd ..
        cd ..
        exit 0
      }
      cd ..
      
      # Build for simulator (x86_64) - static library  
      mkdir -p simulator
      cd simulator
      if [ "$FREETDS_BUILT" = "true" ] && [ -f "../../Frameworks/libsybdb.a" ]; then
        echo "Building with FreeTDS support for simulator (x86_64)..."
        cmake ../../../src \
          -DCMAKE_SYSTEM_NAME=iOS \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
          -DCMAKE_OSX_ARCHITECTURES=x86_64 \
          -DCMAKE_OSX_SYSROOT=iphonesimulator \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF \
          -DFREETDS_INCLUDE_DIR="${PWD}/../../Frameworks/Headers" \
          -DFREETDS_LIBRARY="${PWD}/../../Frameworks/libsybdb.a" || {
          echo "WARNING: CMake with FreeTDS failed, building stub..."
          cmake ../../../src \
            -DCMAKE_SYSTEM_NAME=iOS \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
            -DCMAKE_OSX_ARCHITECTURES=x86_64 \
            -DCMAKE_OSX_SYSROOT=iphonesimulator \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_SHARED_LIBS=OFF
        }
      else
        echo "Building stub implementation for simulator (x86_64)..."
        cmake ../../../src \
          -DCMAKE_SYSTEM_NAME=iOS \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
          -DCMAKE_OSX_ARCHITECTURES=x86_64 \
          -DCMAKE_OSX_SYSROOT=iphonesimulator \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF
      fi
      
      make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 2) || {
        echo "WARNING: Simulator build failed"
        cd ..
        cd ..
        exit 0
      }
      cd ..
      
      # Create universal library from static libs
      if [ -f "device/libmssql_io.a" ] && [ -f "simulator/libmssql_io.a" ]; then
        mkdir -p ../Frameworks
        lipo -create device/libmssql_io.a simulator/libmssql_io.a -output ../Frameworks/libmssql_io.a || {
          echo "WARNING: Failed to create universal library"
          cd ..
          exit 0
        }
        echo "✓ Native libraries built successfully"
      else
        echo "WARNING: Failed to build native libraries. Plugin will use stub."
      fi
      
      cd ..
    else
      echo "✓ Native library already built"
    fi
    
    echo ""
    echo "=========================================="
    echo "iOS preparation complete!"
    echo "=========================================="
  CMD
end

