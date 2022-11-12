// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vellnys/config.dart' as config;
import 'package:vellnys/persistence.dart' as persistence;
import 'welcome.dart';

class Settings extends StatefulWidget {
  final SharedPreferences prefs;

  const Settings({Key? key, required this.prefs}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var _isLoading = true;

  // Prefs
  late var _usesDyslexiaFont;
  late var _usesColouredBackgrounds;
  late var disablesChatRotations;

  _logOut() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Welcome()));
  }

  _toggleDyslexiaSetting(SharedPreferences prefs) async {
    _usesDyslexiaFont = !_usesDyslexiaFont;
  }

  _toggleColouredBackgroundsSetting(SharedPreferences prefs) async {
    _usesColouredBackgrounds = !_usesColouredBackgrounds;
    if (persistence.isColorTheme(prefs, 'colored')) {
      persistence.setColorTheme(prefs, 'default');
    } else {
      persistence.setColorTheme(prefs, 'colored');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  config.body('Use dyslexia-friendly font'),
                  Switch(
                      value: _usesDyslexiaFont,
                      onChanged: _toggleDyslexiaSetting(widget.prefs)),
                ],
              )
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  config.body('Use dyslexia-friendly font'),
                  Switch(
                      value: _usesColouredBackgrounds,
                      onChanged:
                          _toggleColouredBackgroundsSetting(widget.prefs)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24.0),
          config.primaryButton('Sign out', icon: Icons.logout, action: _logOut),
        ],
      ),
    )));
  }
}
