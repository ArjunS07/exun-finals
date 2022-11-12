import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:vellnys/config.dart';
import 'package:vellnys/persistence.dart' as persistence;

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.only(top: 64.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(children: [
            Text("Welcome to", style: heading2TS),
            const SizedBox(height: 4.0),
            Text("Vellnys", style: titleTS),
            const SizedBox(height: 76.0),
            const SizedBox(
                width: 200.0,
                height: 200.0,
                child: Card(
                  color: Colors.green,
                )),
            const SizedBox(height: 76.0),
            Text("Going through tough times alone is hard.", style: bodyTS),
            const SizedBox(height: 36.0),
            Text(
              "Vellnys helps you find the emotional support you need to make it through.",
              style: bodyTS,
              textAlign: TextAlign.center,
            ),
            // TODO: Move this to later screen
            const SizedBox(
              height: 76.0,
            ),
            primaryButton('Get started',
                action: () => {
                      print('Calling function...'),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountSignUp()))
                    })
          ]),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign up'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 24.0, right: 24.0),
          child: Column(children: [
            Icon(Icons.account_circle, size: 100.0, color: primaryColor),
            const SizedBox(height: 30.0),
            Form(
                key: _formKey,
                child: (Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Email",
                            style: descriptiveTS, textAlign: TextAlign.start)),
                    const SizedBox(height: 6.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "you@email.com",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Password",
                            style: descriptiveTS, textAlign: TextAlign.start)),
                    const SizedBox(height: 6.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "super-secret-p@ssw0rd",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Confirm Password",
                            style: descriptiveTS, textAlign: TextAlign.start)),
                    const SizedBox(height: 6.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Text';
                        }
                        return value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "super-secret-p@ssw0rd",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 36.0),
                    primaryButton('Sign Up',
                        action: () => {
                              // ignore: avoid_print
                              print('Calling function...'),
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NameGenerator()))
                            })
                  ],
                )))
          ]),
        ));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 16.0, right: 16.0),
        ),
      ),
    );
  }
}

class NameGenerator extends StatefulWidget {
  const NameGenerator({Key? key}) : super(key: key);

  @override
  _NameGeneratorState createState() => _NameGeneratorState();
}

class _NameGeneratorState extends State<NameGenerator> {
  String generatedName = 'hello';

  void _refreshRandomName() async {
    var request = http.Request(
        'GET', Uri.parse('http://localhost:4996/username-generator'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      setState(() {
        generatedName = res;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshRandomName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a name'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    textAlign: TextAlign.center,
                    "Randomised names let you talk safely and anonymously on LoQui.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                      height: 1.5,
                    )),
                const Spacer(),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Your name is...',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 2.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      generatedName,
                      style: heading2TS,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                      onPressed: _refreshRandomName,
                      style: ButtonStyle(
                        elevation: null,
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.5),
                              side: BorderSide(color: primaryColor)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Generate new name",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16.0,
                                    color: primaryColor)),
                            const SizedBox(width: 8.0),
                            Icon(Icons.restart_alt,
                                size: 32.0, color: primaryColor)
                          ],
                        ),
                      )),
                ]),
                const Spacer(),
                primaryButton("Confirm name",
                    action: () => {
                          // ignore: avoid_print
                          print('Calling function...'),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserDetails()))
                        })
              ])),
    );
  }
}

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key}) : super(key: key);
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<UserDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 24.0, right: 24.0),
          child: Column(
            children: [
              Text('What Problems are you facing?', style: heading2TS),
              const SizedBox(height: 12.0),
              Text(
                  textAlign: TextAlign.start,
                  "We'll use this to match you with others who'll be best able to understand you. No one can see this data..",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    height: 1.5,
                  )),
              Text(
                "Where do you live?",
                style: descriptiveTS,
              ),
              const Spacer(),
              Text(
                "Are you feeling better than you were last week?",
                style: descriptiveTS,
              ),
            ],
          )),
    );
  }
}
