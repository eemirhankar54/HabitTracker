// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emülatör için 10.0.2.2, gerçek cihaz için bilgisayarının IP'si
  static const String _base = 'http://10.206.181.36:8000';
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: _headers,
      body: jsonEncode(
          {'email': email, 'username': username, 'password': password}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(
      Uri.parse('$_base/auth/me'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<void> deleteAccount() async {
    final res = await http.delete(
      Uri.parse('$_base/auth/delete-account'),
      headers: _headers,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      _handle(res);
    }
  }

  // ── Habits ────────────────────────────────────────────────

  Future<List<dynamic>> getHabits() async {
    final res = await http.get(Uri.parse('$_base/habits/'), headers: _headers);
    return _handle(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createHabit(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$_base/habits/'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateHabit(
      int id, Map<String, dynamic> payload) async {
    final res = await http.patch(
      Uri.parse('$_base/habits/$id'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return _handle(res);
  }

  Future<void> deleteHabit(int id) async {
    await http.delete(Uri.parse('$_base/habits/$id'), headers: _headers);
  }

  // ── Logs ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> logHabit(int habitId, {String note = ''}) async {
    final res = await http.post(
      Uri.parse('$_base/habits/log'),
      headers: _headers,
      body: jsonEncode({'habit_id': habitId, 'note': note}),
    );
    return _handle(res);
  }

  Future<void> unlogHabit(int logId) async {
    await http.delete(Uri.parse('$_base/habits/log/$logId'), headers: _headers);
  }

  // ── Stats ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final res =
        await http.get(Uri.parse('$_base/habits/stats'), headers: _headers);
    return _handle(res);
  }

  // ── FCM Token Güncelleme ──────────────────────────────────

  Future<void> updateFCMToken(String token) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/update-fcm-token'),
        headers: _headers,
        body: jsonEncode({'token': token}),
      );
      _handle(res);
    } catch (e) {
      debugPrint("Token güncellenirken hata oluştu: $e");
      rethrow;
    }
  }

  // ── Helper ────────────────────────────────────────────────

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body);
    }

    // Backend 422 verirse detayları görelim
    if (res.statusCode == 422) {
      debugPrint("Backend Validasyon Hatası (422): ${res.body}");
    }

    String detail = 'Bir hata oluştu';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map) {
        detail = decoded['detail'] ?? detail;
      }
    } catch (_) {}
    throw Exception(detail);
  }
}

final apiService = ApiService();
