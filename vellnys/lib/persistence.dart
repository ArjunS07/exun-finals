import 'package:shared_preferences/shared_preferences.dart';

void rememberLogin() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('loggedIn', true);
}

void forgetLogin() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('loggedIn', false);
}
