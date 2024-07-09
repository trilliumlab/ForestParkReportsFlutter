import 'package:drift/drift.dart';

Never _unsupported() {
  throw UnsupportedError("No suitable database implementation was found on this platform.");
}

QueryExecutor openDatabase() {
  _unsupported();
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  _unsupported();
}
