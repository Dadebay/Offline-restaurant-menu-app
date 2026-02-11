import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usernameKey = 'admin_username';
  static const String _passwordKey = 'admin_password';
  static const String _defaultUsername = 'admin';
  static const String _defaultPassword = 'admin123';

  /// Get stored username (or default)
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? _defaultUsername;
  }

  /// Get stored password (or default)
  Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) ?? _defaultPassword;
  }

  /// Verify login credentials
  Future<bool> login(String username, String password) async {
    final storedUsername = await getUsername();
    final storedPassword = await getPassword();
    return username == storedUsername && password == storedPassword;
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final storedPassword = await getPassword();
    if (currentPassword != storedPassword) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
    return true;
  }

  /// Reset to default credentials
  Future<void> resetCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_passwordKey);
  }
}
