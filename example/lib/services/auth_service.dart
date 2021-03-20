import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    return true;
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    return true;
  }

  Future<String?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}
