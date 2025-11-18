import 'dart:async';
import 'dart:convert';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;

import 'src/models/query_result.dart';
import 'src/models/sql_parameter.dart';
import 'src/exceptions/mssql_exceptions.dart';

/// Web implementation of MSSQL IO plugin
/// 
/// Note: Web platform cannot use FFI, so it requires a backend API server
/// to proxy SQL Server requests. This is a security-conscious design that
/// prevents exposing database credentials in web applications.
class MssqlIoWeb {
  static void registerWith(Registrar registrar) {
    // Web plugin registration
  }

  /// Singleton instance for web
  static MssqlIoWeb? _instance;
  
  String? _apiBaseUrl;
  String? _authToken;
  bool _isConfigured = false;

  static MssqlIoWeb getInstance() {
    _instance ??= MssqlIoWeb._internal();
    return _instance!;
  }

  MssqlIoWeb._internal();

  /// Configure the API endpoint for SQL Server proxy
  /// 
  /// Web applications MUST use a backend API server to connect to SQL Server
  /// for security reasons. Never expose database credentials in web code!
  /// 
  /// Example:
  /// ```dart
  /// MssqlIoWeb.getInstance().configure(
  ///   apiBaseUrl: 'https://your-api.com/sql',
  ///   authToken: 'your-auth-token',
  /// );
  /// ```
  void configure({
    required String apiBaseUrl,
    String? authToken,
  }) {
    _apiBaseUrl = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
    _authToken = authToken;
    _isConfigured = true;
  }

  /// Execute a query via the backend API
  /// 
  /// Sends a POST request to your backend API with query details
  Future<QueryResult> executeQuery(
    String query, {
    List<SqlParameter>? parameters,
  }) async {
    _ensureConfigured();

    try {
      final response = await http.post(
        Uri.parse('${_apiBaseUrl}query'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'query': query,
          if (parameters != null)
            'parameters': parameters
                .map((p) => {
                      'name': p.name,
                      'value': p.value,
                      'type': p.type?.sqlTypeName,
                    })
                .toList(),
        }),
      );

      if (response.statusCode == 200) {
        return QueryResult.fromJson(response.body);
      } else {
        throw QueryException(
          'Query failed',
          query: query,
          details: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is QueryException) rethrow;
      throw QueryException(
        'Query execution failed',
        query: query,
        details: e.toString(),
      );
    }
  }

  /// Execute a write operation via the backend API
  Future<int> executeWrite(
    String query, {
    List<SqlParameter>? parameters,
  }) async {
    _ensureConfigured();

    try {
      final response = await http.post(
        Uri.parse('${_apiBaseUrl}execute'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'query': query,
          if (parameters != null)
            'parameters': parameters
                .map((p) => {
                      'name': p.name,
                      'value': p.value,
                      'type': p.type?.sqlTypeName,
                    })
                .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return (result['affected'] as num?)?.toInt() ?? 0;
      } else {
        throw QueryException(
          'Write operation failed',
          query: query,
          details: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is QueryException) rethrow;
      throw QueryException(
        'Write operation failed',
        query: query,
        details: e.toString(),
      );
    }
  }

  void _ensureConfigured() {
    if (!_isConfigured || _apiBaseUrl == null) {
      throw ConnectionException(
        'Web API not configured. Call configure() first with your backend API URL.',
      );
    }
  }
}

