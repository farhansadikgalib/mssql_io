#include "include/mssql_io/mssql_io_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define MSSQL_IO_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), mssql_io_plugin_get_type(), \
                               MssqlIoPlugin))

struct _MssqlIoPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(MssqlIoPlugin, mssql_io_plugin, g_object_get_type())

// Called when the plugin is registered
static void mssql_io_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(mssql_io_plugin_parent_class)->dispose(object);
}

static void mssql_io_plugin_class_init(MssqlIoPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = mssql_io_plugin_dispose;
}

static void mssql_io_plugin_init(MssqlIoPlugin* self) {}

void mssql_io_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  // This is an FFI plugin - native library is loaded via dart:ffi
  // No method channels needed
}

