import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vellnys/screens/settings.dart';

class BottomTabController extends StatefulWidget {
  final SharedPreferences prefs;

  const BottomTabController({Key? key, required this.prefs}) : super(key: key);

  @override
  State<BottomTabController> createState() => _BottomTabControllerState();
}

class _BottomTabControllerState extends State<BottomTabController> {
  var _isLoading = true;
  int _index = 0;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
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
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Volunteers"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _bottomTabController() {
    Widget child = Container();

    switch (_index) {
      case 0:
        child = Container();
        break;
      case 1:
        child = Container();
        break;
      case 2:
        child = Container();
        break;
    }
    return Scaffold(
      body: SizedBox.expand(child: child),
      bottomNavigationBar: BottomNavigationBar(
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
    return _isLoading
        ? const Scaffold(
            body: SizedBox.expand(
                child: Center(
            child: CircularProgressIndicator(),
          )))
        : _tabController();
  }
}
