import 'dart:convert';
import 'package:drift/drift.dart';

class JsonMapConverter<V> extends TypeConverter<Map<String, V>, String> {
  const JsonMapConverter();

  @override
  Map<String, V> fromSql(String fromDb) =>
      Map<String, V>.from(jsonDecode(fromDb));

  @override
  String toSql(Map<String, V> value) =>
      jsonEncode(value);
}

class JsonListConverter<V> extends TypeConverter<List<V>, String> {
  const JsonListConverter();

  @override
  List<V> fromSql(String fromDb) =>
      List<V>.from(jsonDecode(fromDb));

  @override
  String toSql(List<V> value) =>
      jsonEncode(value);
}
