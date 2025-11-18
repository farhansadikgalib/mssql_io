Pod::Spec.new do |s|
  s.name             = 'mssql_io'
  s.version          = '0.0.2'
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
      
      # Build for device (arm64)
      cmake ../../src \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_C_FLAGS="-fembed-bitcode" \
        -DCMAKE_CXX_FLAGS="-fembed-bitcode" \
        -DFREETDS_INCLUDE_DIR="${PWD}/../Frameworks/Headers" \
        -DFREETDS_LIBRARY="${PWD}/../Frameworks/libsybdb.a"
      
      make
      cp libmssql_io.dylib ../Frameworks/libmssql_io_device.a
      
      # Build for simulator (x86_64)
      rm -rf *
      cmake ../../src \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
        -DCMAKE_OSX_ARCHITECTURES=x86_64 \
        -DCMAKE_OSX_SYSROOT=iphonesimulator \
        -DFREETDS_INCLUDE_DIR="${PWD}/../Frameworks/Headers" \
        -DFREETDS_LIBRARY="${PWD}/../Frameworks/libsybdb.a"
      
      make
      cp libmssql_io.dylib ../Frameworks/libmssql_io_sim.a
      
      # Create universal library
      cd ..
      lipo -create Frameworks/libmssql_io_device.a Frameworks/libmssql_io_sim.a -output Frameworks/libmssql_io.a
      rm Frameworks/libmssql_io_device.a Frameworks/libmssql_io_sim.a
      
      echo "✓ Native libraries built successfully"
    else
      echo "Native library already built"
    fi
  CMD
end

