import 'package:flutter/foundation.dart';

class ApiConfiguration {
  ApiConfiguration._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'READPACK_API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    }

    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:4000/api/v1';
  }
}
