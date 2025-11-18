import 'package:flutter_test/flutter_test.dart';
import 'package:mssql_io/mssql_io.dart';

void main() {
  group('SqlParameter', () {
    test('creates with name and value', () {
      final param = SqlParameter(name: 'age', value: 25);

      expect(param.name, 'age');
      expect(param.value, 25);
      expect(param.type, isNull);
    });

    test('creates with explicit type', () {
      final param = SqlParameter.typed(
        name: 'name',
        value: 'Alice',
        type: SqlType.string,
      );

      expect(param.name, 'name');
      expect(param.value, 'Alice');
      expect(param.type, SqlType.string);
    });

    test('toString includes all info', () {
      final param = SqlParameter(name: 'id', value: 123);
      final str = param.toString();

      expect(str, contains('id'));
      expect(str, contains('123'));
    });
  });

  group('SqlType', () {
    test('string type has correct SQL name', () {
      expect(SqlType.string.sqlTypeName, 'NVARCHAR');
    });

    test('integer type has correct SQL name', () {
      expect(SqlType.integer.sqlTypeName, 'INT');
    });

    test('bigInt type has correct SQL name', () {
      expect(SqlType.bigInt.sqlTypeName, 'BIGINT');
    });

    test('float type has correct SQL name', () {
      expect(SqlType.float.sqlTypeName, 'FLOAT');
    });

    test('decimal type has correct SQL name', () {
      expect(SqlType.decimal.sqlTypeName, 'DECIMAL');
    });

    test('boolean type has correct SQL name', () {
      expect(SqlType.boolean.sqlTypeName, 'BIT');
    });

    test('dateTime type has correct SQL name', () {
      expect(SqlType.dateTime.sqlTypeName, 'DATETIME2');
    });

    test('date type has correct SQL name', () {
      expect(SqlType.date.sqlTypeName, 'DATE');
    });

    test('time type has correct SQL name', () {
      expect(SqlType.time.sqlTypeName, 'TIME');
    });

    test('binary type has correct SQL name', () {
      expect(SqlType.binary.sqlTypeName, 'VARBINARY');
    });

    test('guid type has correct SQL name', () {
      expect(SqlType.guid.sqlTypeName, 'UNIQUEIDENTIFIER');
    });

    test('null type has correct SQL name', () {
      expect(SqlType.null_.sqlTypeName, 'NULL');
    });
  });
}
