import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vellnys/persistence.dart' as persistence;
import 'package:vellnys/config.dart' as config;

import 'package:vellnys/screens/settings.dart';

class BottomTabController extends StatefulWidget {
  final SharedPreferences prefs;

  const BottomTabController({Key? key, required this.prefs}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  int _index = 0;

  @override
  void initState() {
    setState(() {
      _index = persistence.getTabState(widget.prefs) ?? 0;
    });
    super.initState();
  }

  Widget _tabController() {
    Widget child = Container();
    switch (_index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        child = Settings(prefs: widget.prefs);
        break;
    }
    return Scaffold(
      body: SizedBox.expand(child: child),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: config.primaryColor,
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: "Connect"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Premium"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tabController();
  }
}
