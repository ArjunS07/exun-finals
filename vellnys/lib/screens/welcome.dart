import 'package:flutter/material.dart';

import 'package:vellnys/config.dart';
import 'package:vellnys/persistence.dart'
    as persistence; // TODO: Import the functions from here

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(children: [
            Text("Welcome to", style: heading2TS),
            Text("Vellnys", style: heading1TS),
          ])
        ],
      ),
    )));
  }
}

class AccountSignUp extends StatefulWidget {
  const AccountSignUp({Key? key}) : super(key: key);

  @override
  _AccountSignUpState createState() => _AccountSignUpState();
}

class _AccountSignUpState extends State<AccountSignUp> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NameGenerator extends StatefulWidget {
  const NameGenerator({Key? key}) : super(key: key);

  @override
  _NameGeneratorState createState() => _NameGeneratorState();
}

class _NameGeneratorState extends State<NameGenerator> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
