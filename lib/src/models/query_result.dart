import 'dart:convert';

/// Result from a SQL query execution
///
/// JSON schema: { columns: [string], rows: [object|array], affected: number }
class QueryResult {
  /// Column names in the result set
  final List<String> columns;

  /// Rows of data - each row is a Map of column name to value
  final List<Map<String, dynamic>> rows;

  /// Number of rows affected (for INSERT/UPDATE/DELETE)
  final int affectedRows;

  const QueryResult({
    required this.columns,
    required this.rows,
    required this.affectedRows,
  });

  /// Parse from JSON string returned by native layer
  factory QueryResult.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      final List<String> columns = (json['columns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final List<Map<String, dynamic>> rows =
          (json['rows'] as List<dynamic>?)?.map((row) {
                if (row is Map) {
                  return Map<String, dynamic>.from(row);
                } else if (row is List) {
                  // Convert array format to map using column names
                  final Map<String, dynamic> rowMap = {};
                  for (int i = 0; i < columns.length && i < row.length; i++) {
                    rowMap[columns[i]] = row[i];
                  }
                  return rowMap;
                }
                return <String, dynamic>{};
              }).toList() ??
              [];

      final int affectedRows = (json['affected'] as num?)?.toInt() ?? 0;

      return QueryResult(
        columns: columns,
        rows: rows,
        affectedRows: affectedRows,
      );
    } catch (e) {
      throw FormatException('Failed to parse query result: $e');
    }
  }

  /// Convert to JSON string
  String toJson() {
    return jsonEncode({
      'columns': columns,
      'rows': rows,
      'affected': affectedRows,
    });
  }

  /// Get first row or null if no rows
  Map<String, dynamic>? get firstOrNull => rows.isEmpty ? null : rows.first;

  /// Check if result is empty
  bool get isEmpty => rows.isEmpty;

  /// Check if result has data
  bool get isNotEmpty => rows.isNotEmpty;

  /// Number of rows returned
  int get rowCount => rows.length;

  @override
  String toString() {
    return 'QueryResult(columns: $columns, rowCount: $rowCount, affected: $affectedRows)';
  }
}































