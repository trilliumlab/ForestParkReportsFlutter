// Conditional export to expose the right connection factory depending
// on the platform. Do not import anything from `_connection` directly!
export '_connection/unsupported.dart'
  if (dart.library.js) '_connection/web.dart'
  if (dart.library.ffi) '_connection/native.dart';
