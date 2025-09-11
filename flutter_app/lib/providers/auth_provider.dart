import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  String? _access;
  String? _refresh;

  bool get isAuthenticated => (_access ?? '').isNotEmpty;
  String? get accessToken => _access;

  Future<void> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    _access = sp.getString('access');
    _refresh = sp.getString('refresh');
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final api = ApiClient();
      final res = await api.post('/api/auth/register/', {
        'name': name,
        'email': email,
        'password': password,
      });
      if (res['success'] == true) return null;
      return res['message']?.toString() ?? 'Registration failed';
    } catch (e) {
      return _extractMessage(e) ?? 'Registration failed';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final api = ApiClient();
      final res = await api.post('/api/auth/token/', {
        'email': email,
        'password': password,
      });
      if (res['success'] == true) {
        _access = res['data']['access'];
        _refresh = res['data']['refresh'];
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', _access!);
        await sp.setString('refresh', _refresh!);
        notifyListeners();
        return null;
      }
      return res['message']?.toString() ?? 'Login failed';
    } catch (e) {
      return _extractMessage(e) ?? 'Login failed';
    }
  }

  Future<void> logout() async {
    _access = null;
    _refresh = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access');
    await sp.remove('refresh');
    notifyListeners();
  }

  String? _extractMessage(Object e) {
    final s = e.toString();
    // Try to parse JSON directly
    try {
      final map = jsonDecode(s);
      if (map is Map && map['message'] is String) return map['message'] as String;
      if (map is Map && map['detail'] is String) return map['detail'] as String;
    } catch (_) {
      // Try to locate JSON inside the exception string
      final start = s.indexOf('{');
      final end = s.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonPart = s.substring(start, end + 1);
        try {
          final map = jsonDecode(jsonPart);
          if (map is Map && map['message'] is String) return map['message'] as String;
          if (map is Map && map['detail'] is String) return map['detail'] as String;
        } catch (_) {}
      }
    }
    return null;
  }
}



