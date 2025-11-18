import Cocoa
import FlutterMacOS

public class MssqlIoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // This is an FFI plugin - no method channel needed
    // Native library is loaded via dart:ffi
  }
}

