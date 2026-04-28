// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isChecking = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        apiService.setToken(token);
        _isLoggedIn = true;
        // Backend'den güncel kullanıcı bilgilerini çek
        await fetchProfile();
      }
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Backend'den /auth/me endpoint'inden kullanıcı profilini çeker
  Future<void> fetchProfile() async {
    try {
      final data = await apiService.getMe();
      _user = data;
      notifyListeners();
    } catch (e) {
      debugPrint("Profil çekme hatası: $e");
    }
  }

  Future<String?> login(
      {required String email, required String password}) async {
    _setLoading(true);
    try {
      final data = await apiService.login(email: email, password: password);
      await _saveSession(data);
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // lib/providers/auth_provider.dart veya main.dart içinde
  Future<void> syncFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await apiService.updateFCMToken(token);
      }
    } catch (e) {
      debugPrint("FCM Token sync hatası: $e");
    }
  }

  Future<void> initializeNotifications() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await apiService.updateFCMToken(token);
        debugPrint("FCM Token başarıyla backend'e kaydedildi: $token");
      }
    } catch (e) {
      debugPrint("Bildirim başlatma hatası: $e");
    }
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Kullanıcı bildirim izni verdi! ✅');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('Kullanıcı geçici izin verdi (iOS).');
    } else {
      debugPrint('Kullanıcı izin vermedi! ❌');
    }
  }

  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final data = await apiService.register(
        email: email,
        username: username,
        password: password,
      );
      await _saveSession(data);
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Hesabı kalıcı olarak siler
  Future<String?> deleteAccount() async {
    _setLoading(true);
    try {
      await apiService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      apiService.clearToken();
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    apiService.clearToken();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) throw Exception('Token alınamadı');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    apiService.setToken(token);
    _user = data['user'] as Map<String, dynamic>?;
    _isLoggedIn = true;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
