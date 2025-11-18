#include "include/mssql_io/mssql_io_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/plugin_registrar_windows.h>

namespace {

class MssqlIoPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MssqlIoPlugin();

  virtual ~MssqlIoPlugin();

 private:
};

// static
void MssqlIoPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  // This is an FFI plugin - native library is loaded via dart:ffi
  // No method channels needed
}

MssqlIoPlugin::MssqlIoPlugin() {}

MssqlIoPlugin::~MssqlIoPlugin() {}

}  // namespace

void MssqlIoPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  MssqlIoPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

