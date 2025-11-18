#import "MssqlIoPlugin.h"

@implementation MssqlIoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  // This is an FFI plugin - no method channel needed
  // Native library is loaded via dart:ffi
}

@end

