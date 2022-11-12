// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loqui/config.dart' as config;
import 'package:loqui/persistence.dart' as persistence;
import 'welcome.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Settings extends StatefulWidget {
  final SharedPreferences prefs;

  const Settings({Key? key, required this.prefs}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _logout() {
    persistence.forgetLogin(widget.prefs);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Welcome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Settings'),
          backgroundColor: Colors.blue.shade800,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: SettingsList(
                sections: [
                  SettingsSection(
                    title: const Text('Theme'),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        value: const Text('English'),
                      ),
                      SettingsTile.switchTile(
                        // onToggle: (value) {!value},
                        onToggle: null,
                        initialValue: true,
                        leading: const Icon(Icons.format_paint),
                        title: const Text('Use Dyslexic Theme'),
                      ),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: 24.0),
              config.primaryButton('Sign out',
                  icon: Icons.logout, action: _logout),
            ],
          ),
        ));
  }
}
