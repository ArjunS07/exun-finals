import 'package:flutter/material.dart';
import 'package:loqui/screens/chats.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loqui/persistence.dart' as persistence;
import 'package:loqui/config.dart' as config;
import 'package:loqui/screens/premium.dart';

import 'package:loqui/screens/settings.dart';

class BottomTabController extends StatefulWidget {
  final SharedPreferences prefs;
  const BottomTabController({Key? key, required this.prefs}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  int _index = 0;

  // late SharedPreferences? prefs;

  // void _getPrefs() async {
  //   prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _isLoading = false;
  //   });
  //}
  // join once you're done we'
  @override
  void initState() {
    // prefs = await SharedPreferences.getInstance();

    setState(() {
      _index = persistence.getTabState(widget.prefs) ?? 0;
    });
    super.initState();
  }

  Widget _tabController() {
    Widget child = Container();
    switch (_index) {
      case 0:
        child = ChatList(prefs: widget.prefs);
        break;
      case 1:
        child = Settings(prefs: widget.prefs);
        break;
      case 2:
        child = const Premium();
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
