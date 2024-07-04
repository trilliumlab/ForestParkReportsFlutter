import 'dart:convert';
import 'package:drift/drift.dart';

class JsonObjectConverter<T> extends TypeConverter<T, String> {
  const JsonObjectConverter();

  @override
  T fromSql(String fromDb) =>
      jsonDecode(fromDb);

  @override
  String toSql(T value) =>
      jsonEncode(value);
}
