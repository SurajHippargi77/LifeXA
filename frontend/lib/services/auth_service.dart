import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── API base URL ──────────────────────────────────────────────────────────────
const String _kBaseUrl =
    kIsWeb ? 'http://127.0.0.1:8001' : 'http://10.0.2.2:8001';

// ── Session (ChangeNotifier so widgets can watch auth state) ──────────────────
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? _token;
  String? _userName;
  String? _userEmail;

  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _token != null;

  void setSession({
    required String token,
    String? userName,
    String? userEmail,
  }) {
    _token = token;
    _userName = userName;
    _userEmail = userEmail;
    notifyListeners();
  }

  // Keep old name for backward compat
  void setToken(String token) => setSession(token: token);

  void clear() {
    _token = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}

// ── Result type ───────────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? token;
  final String? error;
  const AuthResult({required this.success, this.token, this.error});
}

// ── Service ───────────────────────────────────────────────────────────────────
class AuthService {
  AuthService._();

  /// POST /auth/login
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_kBaseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        AuthSession.instance.setSession(token: token, userEmail: email);
        return AuthResult(success: true, token: token);
      }

      return AuthResult(
        success: false,
        error: _friendlyError(res.statusCode, res.body),
      );
    } on Exception {
      return const AuthResult(
        success: false,
        error: 'Unable to connect to LifeXA. Please try again.',
      );
    }
  }

  /// POST /auth/signup
  static Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_kBaseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 201) {
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        error: _friendlyError(res.statusCode, res.body),
      );
    } on Exception {
      return const AuthResult(
        success: false,
        error: 'Unable to connect to LifeXA. Please try again.',
      );
    }
  }

  /// TODO: backend email verification contract still required.
  /// Expected contract once supported by the API:
  /// - POST /auth/verify-email { email, code }
  /// - POST /auth/resend-verification { email }
  /// - Optional: GET /auth/verification-status?email=...
  /// The frontend is implemented now and will integrate as soon as the backend exposes
  /// the exact endpoint contract.
  static Future<AuthResult> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    return const AuthResult(
      success: false,
      error: 'Email verification is not yet supported by the backend. Please try again later.',
    );
  }

  static Future<AuthResult> resendVerificationCode({
    required String email,
  }) async {
    return const AuthResult(
      success: false,
      error: 'Email verification is not yet supported by the backend. Please try again later.',
    );
  }

  /// POST /chat  (requires auth token)
  static Future<AuthResult> chat({required String message}) async {
    final token = AuthSession.instance.token;
    if (token == null) {
      return const AuthResult(success: false, error: 'Not authenticated');
    }
    try {
      final res = await http
          .post(
            Uri.parse('$_kBaseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AuthResult(success: true, token: data['reply'] as String?);
      }
      if (res.statusCode == 401) {
        AuthSession.instance.clear();
        return const AuthResult(success: false, error: 'session_expired');
      }
      return AuthResult(
        success: false,
        error: _friendlyError(res.statusCode, res.body),
      );
    } on Exception {
      return const AuthResult(
        success: false,
        error: 'Unable to reach LifeXA. Please try again.',
      );
    }
  }

  static String _friendlyError(int statusCode, String body) {
    String? detail;
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final raw = data['detail'];
      if (raw is String) detail = raw;
    } catch (_) {}

    if (detail != null) {
      if (detail.toLowerCase().contains('already registered')) {
        return 'An account with this email already exists.';
      }
      if (detail.toLowerCase().contains('invalid email or password')) {
        return 'Invalid email or password. Please try again.';
      }
      if (detail.toLowerCase().contains('jwt_secret_key')) {
        return 'Server configuration error. Please contact support.';
      }
    }

    switch (statusCode) {
      case 400:
        return detail ?? 'Invalid request. Please check your details.';
      case 401:
        return 'Invalid email or password. Please try again.';
      case 422:
        return 'Please check your details and try again.';
      case 500:
      case 502:
      case 503:
        return 'LifeXA is temporarily unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
