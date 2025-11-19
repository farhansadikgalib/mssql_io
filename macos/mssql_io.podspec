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
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  # Build native library
  s.vendored_libraries = 'Frameworks/libmssql_io.dylib'
  
  # FreeTDS via Homebrew
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) /opt/homebrew/include /usr/local/include',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) /opt/homebrew/lib /usr/local/lib',
    'OTHER_LDFLAGS' => '-lsybdb'
  }

  s.swift_version = '5.0'
  
  # Script to build native library
  s.prepare_command = <<-CMD
    if [ ! -f "Frameworks/libmssql_io.dylib" ]; then
      echo "Building native library for macOS..."
      mkdir -p build
      cd build
      cmake ../../src
      make
      mkdir -p ../Frameworks
      cp libmssql_io.dylib ../Frameworks/
    fi
  CMD
end

