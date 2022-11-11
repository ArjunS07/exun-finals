import 'package:shared_preferences/shared_preferences.dart';

void rememberLogin() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('loggedIn', true);
}

void saveTabState(int index) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('lastTab', index);
}

void forgetLogin() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('loggedIn', false);
}
