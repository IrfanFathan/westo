// Conditional export for Platform class
// Uses dart:io on mobile/desktop, stub on web
export 'platform_stub.dart'
    if (dart.library.io) 'platform_io.dart';
