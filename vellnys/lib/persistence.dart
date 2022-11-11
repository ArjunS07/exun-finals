import 'package:shared_preferences/shared_preferences.dart';

void rememberLogin(
  SharedPreferences prefs,
) {
  prefs.setBool('loggedIn', true);
}

void forgetLogin(
  SharedPreferences prefs,
) {
  prefs.setBool('loggedIn', false);
}

isLoggedIn(
  SharedPreferences prefs,
) {
  return (prefs.getBool('loggedIn') == true);
}

void saveTabState(SharedPreferences prefs, int index) async {
  prefs.setInt('lastTab', index);
}

getTabState(
  SharedPreferences prefs,
) {
  return prefs.getInt('lastTab');
}

void makeDyslexicFont(
  SharedPreferences prefs,
) {
  prefs.setBool('isDyslexicFont', true);
}

void makeNormalFont(
  SharedPreferences prefs,
) {
  prefs.setBool('isDyslexicFont', false);
}

isDyslexicFont(
  SharedPreferences prefs,
) {
  var isDyslexic = prefs.getBool('isDyslexicFont');
  return isDyslexic;
}
