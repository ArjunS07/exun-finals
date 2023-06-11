import 'package:shared_preferences/shared_preferences.dart';

void rememberLogin(SharedPreferences prefs, {firebaseUserId}) {
  prefs.setBool('loggedIn', true);

  if (firebaseUserId != null) {
    prefs.setString('firebaseUserId', firebaseUserId);
  }
}

void forgetLogin(
  SharedPreferences prefs,
) {
  prefs.setBool('loggedIn', false);
  prefs.remove('firebaseUserId');
}

String? firebaseUserId(SharedPreferences prefs) {
  var id = prefs.getString('firebaseUserId');
  return id;
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

void setColorTheme(SharedPreferences prefs, String theme) {
  prefs.setString('theme', theme);
}

isColorTheme(
  SharedPreferences prefs,
  String colorTheme,
) {
  return prefs.getString('theme') == colorTheme;
}
