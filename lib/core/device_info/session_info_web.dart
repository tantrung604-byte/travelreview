// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web: lấy UserAgent từ navigator + IP từ api.ipify.org
Future<Map<String, String>> getSessionInfo() async {
  final ua = html.window.navigator.userAgent;
  String ip = '';
  try {
    final result = await html.HttpRequest.getString(
      'https://api.ipify.org?format=text',
    );
    ip = result.trim();
  } catch (_) {
    // Silently fail – IP không bắt buộc
  }
  return {
    'ip': ip,
    'userAgent': ua,
    'platform': 'web',
  };
}

