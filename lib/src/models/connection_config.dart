/// Configuration for establishing a connection to SQL Server
class ConnectionConfig {
  /// Server IP address or hostname
  final String host;

  /// Server port (default is 1433)
  final int port;

  /// Database name to connect to
  final String databaseName;

  /// Username for SQL authentication
  final String username;

  /// Password for SQL authentication
  final String password;

  /// Connection timeout in seconds (default is 15)
  final int timeoutInSeconds;

  /// Enable TLS/SSL encryption (depends on FreeTDS configuration)
  final bool enableTls;

  /// Auto-reconnect on connection loss
  final bool autoReconnect;

  /// Maximum reconnection attempts (default is 3)
  final int maxReconnectAttempts;

  /// Reconnection delay in seconds (default is 2)
  final int reconnectDelaySeconds;

  const ConnectionConfig({
    required this.host,
    this.port = 1433,
    required this.databaseName,
    required this.username,
    required this.password,
    this.timeoutInSeconds = 15,
    this.enableTls = true,
    this.autoReconnect = false,
    this.maxReconnectAttempts = 3,
    this.reconnectDelaySeconds = 2,
  });

  /// Create a copy with modified fields
  ConnectionConfig copyWith({
    String? host,
    int? port,
    String? databaseName,
    String? username,
    String? password,
    int? timeoutInSeconds,
    bool? enableTls,
    bool? autoReconnect,
    int? maxReconnectAttempts,
    int? reconnectDelaySeconds,
  }) {
    return ConnectionConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      databaseName: databaseName ?? this.databaseName,
      username: username ?? this.username,
      password: password ?? this.password,
      timeoutInSeconds: timeoutInSeconds ?? this.timeoutInSeconds,
      enableTls: enableTls ?? this.enableTls,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      reconnectDelaySeconds:
          reconnectDelaySeconds ?? this.reconnectDelaySeconds,
    );
  }

  @override
  String toString() {
    // Don't log password for security
    return 'ConnectionConfig(host: $host, port: $port, database: $databaseName, '
        'username: $username, timeout: ${timeoutInSeconds}s, tls: $enableTls)';
  }
}




















