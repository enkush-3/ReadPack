import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:readpack/data/services/api_configuration.dart';

class AuthChallenge {
  final String id;
  final DateTime expiresAt;

  const AuthChallenge({required this.id, required this.expiresAt});

  factory AuthChallenge.fromJson(Map<String, dynamic> json) => AuthChallenge(
    id: json['challengeId'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final Map<String, dynamic> userAccountTree;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userAccountTree,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    userAccountTree: json['userAccountTree'] as Map<String, dynamic>,
  );
}

class AuthApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  const AuthApiException(this.statusCode, this.message, {this.code});

  @override
  String toString() => message;
}

class AuthApiService {
  static const _accessTokenKey = 'readpack_access_token';
  static const _refreshTokenKey = 'readpack_refresh_token';
  static const _storageTimeout = Duration(seconds: 2);

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;
  bool _tokensLoaded = false;
  Future<void>? _tokenLoadInFlight;
  Future<void>? _refreshInFlight;

  AuthApiService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       baseUrl = baseUrl ?? ApiConfiguration.baseUrl;

  String? get accessToken => _accessToken;

  Future<bool> hasStoredSession() async {
    await _loadTokens();
    return _refreshToken != null;
  }

  Future<AuthChallenge> signUp({
    required String name,
    required String contact,
    required String password,
    required String contactType,
  }) async {
    final json = await _send(
      'POST',
      '/auth/signup',
      body: {
        'name': name.trim(),
        'contact': contact.trim(),
        'password': password,
        'contactType': contactType,
      },
    );
    return AuthChallenge.fromJson(json);
  }

  Future<AuthChallenge> resendOtp(String challengeId) async {
    final json = await _send(
      'POST',
      '/auth/otp/resend',
      body: {'challengeId': challengeId},
    );
    return AuthChallenge.fromJson(json);
  }

  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _send(
      'POST',
      '/auth/otp/verify',
      body: {'challengeId': challengeId, 'code': code},
    );
    return _storeSession(json);
  }

  Future<AuthResult> signIn({
    required String contact,
    required String contactType,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/auth/login',
      body: {
        'contact': contact.trim(),
        'contactType': contactType,
        'password': password,
      },
    );
    return _storeSession(json);
  }

  Future<AuthResult> signInWithProvider({
    required String provider,
    required String token,
  }) async {
    final tokenKey = provider == 'google' ? 'idToken' : 'accessToken';
    final json = await _send(
      'POST',
      '/auth/oauth/$provider',
      body: {tokenKey: token},
    );
    return _storeSession(json);
  }

  Future<AuthChallenge> requestPasswordReset({
    required String contact,
    required String contactType,
  }) async {
    final json = await _send(
      'POST',
      '/auth/password/forgot',
      body: {'contact': contact.trim(), 'contactType': contactType},
    );
    return AuthChallenge.fromJson(json);
  }

  Future<void> resetPassword({
    required String challengeId,
    required String code,
    required String newPassword,
  }) async {
    await _send(
      'POST',
      '/auth/password/reset',
      body: {
        'challengeId': challengeId,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> getUserTree(String userId) =>
      _authenticatedRequest(
        'GET',
        '/users/${Uri.encodeComponent(userId)}/tree',
      );

  Future<Map<String, dynamic>> fetchLeaderboard({String period = 'weekly'}) =>
      _send('GET', '/leaderboard?period=${Uri.encodeQueryComponent(period)}');

  Future<Map<String, dynamic>> requestAuthorized(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) => _authenticatedRequest(method, path, body: body);

  Future<Map<String, dynamic>> updateUserTree(
    String userId,
    Map<String, dynamic> payload,
  ) => _authenticatedRequest(
    'PUT',
    '/users/${Uri.encodeComponent(userId)}/tree',
    body: payload,
  );

  Future<Map<String, dynamic>> _authenticatedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowRefresh = true,
  }) async {
    await _loadTokens();
    final token = _accessToken;
    if (token == null) {
      if (allowRefresh && _refreshToken != null) {
        await refreshSession();
        return _authenticatedRequest(
          method,
          path,
          body: body,
          allowRefresh: false,
        );
      }
      throw const AuthApiException(401, 'Session expired');
    }

    final response = await _request(
      method,
      path,
      body: body,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401 && allowRefresh && _refreshToken != null) {
      await refreshSession();
      return _authenticatedRequest(
        method,
        path,
        body: body,
        allowRefresh: false,
      );
    }
    return _decodeResponse(response);
  }

  Future<void> refreshSession() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final refresh = _performRefresh();
    _refreshInFlight = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_refreshInFlight, refresh)) _refreshInFlight = null;
    }
  }

  Future<void> _performRefresh() async {
    await _loadTokens();
    final refreshToken = _refreshToken;
    if (refreshToken == null) {
      await clearSession();
      throw const AuthApiException(401, 'Session expired');
    }
    try {
      final json = await _send(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );
      await _storeSession(json);
    } on AuthApiException {
      await clearSession();
      rethrow;
    }
  }

  Future<AuthResult> _storeSession(Map<String, dynamic> json) async {
    final result = AuthResult.fromJson(json);
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _tokensLoaded = true;
    try {
      await _secureStorage
          .write(key: _accessTokenKey, value: result.accessToken)
          .timeout(_storageTimeout);
      await _secureStorage
          .write(key: _refreshTokenKey, value: result.refreshToken)
          .timeout(_storageTimeout);
    } catch (_) {
      await clearSession();
      throw const AuthApiException(
        503,
        'Secure session storage is unavailable',
      );
    }
    return result;
  }

  Future<void> logout() async {
    await _loadTokens();
    final refreshToken = _refreshToken;
    if (refreshToken != null) {
      try {
        await _authenticatedRequest(
          'POST',
          '/auth/logout',
          body: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Local credentials are still cleared when the network is unavailable.
      }
    }
    await clearSession();
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _tokensLoaded = true;
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey).timeout(_storageTimeout),
      _secureStorage.delete(key: _refreshTokenKey).timeout(_storageTimeout),
    ]).catchError((Object _) => <void>[]);
  }

  Future<void> _loadTokens() async {
    if (_tokensLoaded) return;
    final existingLoad = _tokenLoadInFlight;
    if (existingLoad != null) {
      await existingLoad;
      return;
    }

    final load = _readStoredTokens();
    _tokenLoadInFlight = load;
    try {
      await load;
    } finally {
      if (identical(_tokenLoadInFlight, load)) _tokenLoadInFlight = null;
    }
  }

  Future<void> _readStoredTokens() async {
    try {
      final tokens = await Future.wait([
        _secureStorage.read(key: _accessTokenKey).timeout(_storageTimeout),
        _secureStorage.read(key: _refreshTokenKey).timeout(_storageTimeout),
      ]);
      _accessToken = tokens[0];
      _refreshToken = tokens[1];
    } catch (_) {
      _accessToken = null;
      _refreshToken = null;
    } finally {
      _tokensLoaded = true;
    }
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _request(method, path, body: body);
    return _decodeResponse(response);
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...headers,
    };
    final encodedBody = body == null ? null : jsonEncode(body);
    final request = switch (method) {
      'GET' => _client.get(uri, headers: requestHeaders),
      'POST' => _client.post(uri, headers: requestHeaders, body: encodedBody),
      'PUT' => _client.put(uri, headers: requestHeaders, body: encodedBody),
      'DELETE' => _client.delete(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      ),
      _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP verb'),
    };
    return request.timeout(const Duration(seconds: 12));
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] as String? ??
          decoded['error'] as String? ??
          'Request failed (${response.statusCode})';
      throw AuthApiException(
        response.statusCode,
        message,
        code: decoded['error'] as String?,
      );
    }
    return decoded;
  }
}
