import 'package:flutter/foundation.dart';
import '../../services/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  Future<AuthResult> login(UserModel user) async {
    try {
      final api = ApiClient();
      final res = await api.post('/api/auth/token/', {
        'email': user.phone, // mapping phone -> email field for this demo
        'password': user.password,
      });
      if (res['success'] == true) {
        return AuthResult(true, 'Login successful');
      }
      return AuthResult(false, res['message']?.toString() ?? 'Login failed');
    } catch (e) {
      return AuthResult(false, 'Login error: ${e.toString()}');
    }
  }

  bool _isLoadingRegistrations = false;
  bool get isLoadingRegistrations => _isLoadingRegistrations;

  Future<AuthResult> register(UserModel user) async {
    try {
      _isLoadingRegistrations = true;
      notifyListeners();
      final api = ApiClient();
      final res = await api.post('/api/auth/register/', {
        'name': user.name,
        'email': user.email ?? user.phone, // allow phone as email placeholder if needed
        'password': user.password,
      });
      if (res['success'] == true) {
        return AuthResult(true, 'Registered successfully');
      }
      return AuthResult(false, res['message']?.toString() ?? 'Registration failed');
    } catch (e) {
      return AuthResult(false, 'Registration error: ${e.toString()}');
    } finally {
      _isLoadingRegistrations = false;
      notifyListeners();
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String message;
  AuthResult(this.isSuccess, this.message);
}


