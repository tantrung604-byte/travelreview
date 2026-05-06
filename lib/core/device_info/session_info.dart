/// Conditional export: web dùng dart:html, các platform khác dùng stub.
export 'session_info_stub.dart'
    if (dart.library.html) 'session_info_web.dart';

