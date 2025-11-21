Pod::Spec.new do |s|
  s.name             = 'mssql_io'
  s.version          = '0.0.3'
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
    echo "Preparing MSSQL IO native libraries for iOS..."
    
    # Build FreeTDS if not already built
    if [ ! -f "Frameworks/libsybdb.a" ]; then
      echo "Building FreeTDS for iOS..."
      bash build_freetds.sh
    else
      echo "FreeTDS already built"
    fi
    
    # Build our native library
    if [ ! -f "Frameworks/libmssql_io.a" ]; then
      echo "Building mssql_io native library..."
      mkdir -p build
      cd build
      
      # Check if cmake is available
      if ! command -v cmake &> /dev/null; then
        echo "Error: cmake is required but not installed. Install with: brew install cmake"
        exit 1
      fi
      
      # Build for device (arm64) - static library
      mkdir -p device
      cd device
      cmake ../../../src \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DFREETDS_INCLUDE_DIR="${PWD}/../../Frameworks/Headers" \
        -DFREETDS_LIBRARY="${PWD}/../../Frameworks/libsybdb.a"
      
      make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 2)
      cd ..
      
      # Build for simulator (x86_64) - static library  
      mkdir -p simulator
      cd simulator
      cmake ../../../src \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
        -DCMAKE_OSX_ARCHITECTURES=x86_64 \
        -DCMAKE_OSX_SYSROOT=iphonesimulator \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DFREETDS_INCLUDE_DIR="${PWD}/../../Frameworks/Headers" \
        -DFREETDS_LIBRARY="${PWD}/../../Frameworks/libsybdb.a"
      
      make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 2)
      cd ..
      
      # Create universal library from static libs
      lipo -create device/libmssql_io.a simulator/libmssql_io.a -output ../Frameworks/libmssql_io.a
      
      cd ..
      echo "✓ Native libraries built successfully"
    else
      echo "Native library already built"
    fi
  CMD
end

