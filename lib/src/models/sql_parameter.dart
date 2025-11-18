/// Represents a SQL parameter for parameterized queries
class SqlParameter {
  /// Parameter name (without @ prefix)
  final String name;

  /// Parameter value
  final dynamic value;

  /// SQL type hint (optional, auto-detected if null)
  final SqlType? type;

  const SqlParameter({
    required this.name,
    required this.value,
    this.type,
  });

  /// Create parameter with explicit type
  const SqlParameter.typed({
    required this.name,
    required this.value,
    required SqlType this.type,
  });

  @override
  String toString() {
    return 'SqlParameter(name: $name, value: $value, type: ${type ?? "auto"})';
  }
}

/// SQL data types for parameter mapping
enum SqlType {
  /// VARCHAR/NVARCHAR
  string,

  /// INT
  integer,

  /// BIGINT
  bigInt,

  /// FLOAT/REAL
  float,

  /// DECIMAL/NUMERIC
  decimal,

  /// BIT
  boolean,

  /// DATETIME/DATETIME2
  dateTime,

  /// DATE
  date,

  /// TIME
  time,

  /// VARBINARY/BINARY (will be Base64 encoded)
  binary,

  /// UNIQUEIDENTIFIER
  guid,

  /// NULL
  null_,
}

/// Extension to get SQL type names
extension SqlTypeExtension on SqlType {
  String get sqlTypeName {
    switch (this) {
      case SqlType.string:
        return 'NVARCHAR';
      case SqlType.integer:
        return 'INT';
      case SqlType.bigInt:
        return 'BIGINT';
      case SqlType.float:
        return 'FLOAT';
      case SqlType.decimal:
        return 'DECIMAL';
      case SqlType.boolean:
        return 'BIT';
      case SqlType.dateTime:
        return 'DATETIME2';
      case SqlType.date:
        return 'DATE';
      case SqlType.time:
        return 'TIME';
      case SqlType.binary:
        return 'VARBINARY';
      case SqlType.guid:
        return 'UNIQUEIDENTIFIER';
      case SqlType.null_:
        return 'NULL';
    }
  }
}
