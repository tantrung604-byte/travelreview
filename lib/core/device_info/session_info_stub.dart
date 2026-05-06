/// Stub cho non-web platforms (Android, iOS, Desktop).
Future<Map<String, String>> getSessionInfo() async {
  return {
    'ip': '',
    'userAgent': '',
    'platform': 'mobile',
  };
}

