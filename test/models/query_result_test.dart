import 'package:flutter_test/flutter_test.dart';
import 'package:mssql_io/mssql_io.dart';

void main() {
  group('QueryResult', () {
    test('parses valid JSON with object rows', () {
      const jsonString = '''
      {
        "columns": ["id", "name", "age"],
        "rows": [
          {"id": 1, "name": "Alice", "age": 25},
          {"id": 2, "name": "Bob", "age": 30}
        ],
        "affected": 0
      }
      ''';

      final result = QueryResult.fromJson(jsonString);

      expect(result.columns, ['id', 'name', 'age']);
      expect(result.rows.length, 2);
      expect(result.rows[0]['name'], 'Alice');
      expect(result.rows[1]['age'], 30);
      expect(result.affectedRows, 0);
    });

    test('parses JSON with array rows', () {
      const jsonString = '''
      {
        "columns": ["id", "name"],
        "rows": [
          [1, "Alice"],
          [2, "Bob"]
        ],
        "affected": 0
      }
      ''';

      final result = QueryResult.fromJson(jsonString);

      expect(result.columns, ['id', 'name']);
      expect(result.rows.length, 2);
      expect(result.rows[0]['id'], 1);
      expect(result.rows[0]['name'], 'Alice');
      expect(result.rows[1]['id'], 2);
      expect(result.rows[1]['name'], 'Bob');
    });

    test('handles null values', () {
      const jsonString = '''
      {
        "columns": ["id", "name", "email"],
        "rows": [
          {"id": 1, "name": "Alice", "email": null}
        ],
        "affected": 0
      }
      ''';

      final result = QueryResult.fromJson(jsonString);

      expect(result.rows[0]['email'], isNull);
    });

    test('handles empty result set', () {
      const jsonString = '''
      {
        "columns": ["id", "name"],
        "rows": [],
        "affected": 0
      }
      ''';

      final result = QueryResult.fromJson(jsonString);

      expect(result.columns, ['id', 'name']);
      expect(result.rows, isEmpty);
      expect(result.isEmpty, true);
      expect(result.isNotEmpty, false);
      expect(result.firstOrNull, isNull);
    });

    test('handles affected rows from write operation', () {
      const jsonString = '''
      {
        "columns": [],
        "rows": [],
        "affected": 5
      }
      ''';

      final result = QueryResult.fromJson(jsonString);

      expect(result.affectedRows, 5);
      expect(result.isEmpty, true);
    });

    test('toJson serializes correctly', () {
      final result = QueryResult(
        columns: ['id', 'name'],
        rows: [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
        ],
        affectedRows: 0,
      );

      final jsonString = result.toJson();
      expect(jsonString, contains('"columns"'));
      expect(jsonString, contains('"rows"'));
      expect(jsonString, contains('"affected"'));
      expect(jsonString, contains('Alice'));
    });

    test('firstOrNull returns first row', () {
      final result = QueryResult(
        columns: ['id'],
        rows: [
          {'id': 1},
          {'id': 2},
        ],
        affectedRows: 0,
      );

      expect(result.firstOrNull, {'id': 1});
    });

    test('rowCount returns correct count', () {
      final result = QueryResult(
        columns: ['id'],
        rows: [
          {'id': 1},
          {'id': 2},
          {'id': 3},
        ],
        affectedRows: 0,
      );

      expect(result.rowCount, 3);
    });

    test('throws FormatException on invalid JSON', () {
      const invalidJson = '{"invalid": json}';

      expect(
        () => QueryResult.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

