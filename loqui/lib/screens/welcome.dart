import 'package:flutter/gestures.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math; // import this
import 'dart:typed_data'; // import this
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dice_bear/dice_bear.dart';
import 'package:loqui/config.dart';
import 'package:loqui/persistence.dart' as persistence;

import 'dart:convert';
import 'dart:typed_data';

import 'package:loqui/screens/tab_controller.dart';

import 'package:loqui/image_utils.dart';

String uint8ListTob64(Uint8List uint8list) {
  String base64String = base64Encode(uint8list);
  String header = "data:image/png;base64,";
  return header + base64String;
}

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding:
          const EdgeInsets.only(top: 64.0, left: 32, right: 32.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome to", style: heading2TS),
                  const SizedBox(height: 30.0),
                  const Image(
                      width: 150.0, image: AssetImage('assets/logo.png')),
                  Text("LoQui", style: titleTS),
                  Spacer(),
                  const Text("Going through tough times alone is hard.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 36.0),
                  const Text(
                      "LoQui helps you find the emotional support you need to make it through.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 36.0),
                  Text(
                      "Connect anonymously with other individuals just like you, and mutually benefit from the power of therapeutic conversation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w400,
                      )),
                  const Spacer(),
                  primaryButton('Get started',
                      action: () => {
                            print('Calling function...'),
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NameGenerator()))
                          })
                ]),
          ),
        ],
      ),
    )));
  }
}

class NameGenerator extends StatefulWidget {
  const NameGenerator({Key? key}) : super(key: key);

  @override
  _NameGeneratorState createState() => _NameGeneratorState();
}

class _NameGeneratorState extends State<NameGenerator> {
  String generatedName = 'hello';
  bool isLoadingName = true;

  void _refreshRandomName() async {
    setState(() {
      isLoadingName = true;
    });
    var request = http.Request(
        'GET', Uri.parse('http://localhost:4996/username-generator'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      setState(() {
        generatedName = res;
        isLoadingName = false;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshRandomName();
    super.initState();
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
                  const SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.center,
                    child: isLoadingName
                        ? CircularProgressIndicator(color: primaryColor)
                        : Text(
                            textAlign: TextAlign.center,
                            generatedName,
                            style: heading2TS,
                          ),
                  ),
                  const SizedBox(height: 24.0),
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
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0,
                                    color: primaryColor)),
                            const SizedBox(width: 8.0),
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: Icon(Icons.restart_alt,
                                  size: 32.0, color: primaryColor),
                            )
                          ],
                        ),
                      )),
                ]),
                const Spacer(),
                primaryButton("Confirm name",
                    action: isLoadingName
                        ? null
                        : () => {
                              // ignore: avoid_print
                              print('Calling function...'),
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserDetails(name: generatedName)))
                            })
              ])),
    );
  }
}

class UserDetails extends StatefulWidget {
  final String name;
  const UserDetails({Key? key, required this.name}) : super(key: key);
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<UserDetails> {
  final TextEditingController _ageController = TextEditingController();

  bool _isMale = false;
  bool _hasChosenGender = false;

  bool _isMakingAccount = false;

  // Location variables
  String? _country;
  String? _state;
  String? _city;

  List conditions = [
    'depression',
    'schizophrenia',
    'ptsd',
    'cancer',
    'diabetes',
    'dementia',
    'anxiety',
    'bipolar'
  ];

  List selectedConditions = [];

  // firebase
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
        backgroundColor: primaryColor,
      ),
      body: _isMakingAccount
          ? const Center(
              child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator()))
          : Padding(
              padding: const EdgeInsets.only(
                  top: 40.0, left: 24.0, right: 24.0, bottom: 40.0),
              child: Column(
                children: [
                  Text('Tell us a bit about yourself', style: heading2TS),
                  const SizedBox(height: 24.0),
                  Text(
                      textAlign: TextAlign.start,
                      "We'll use this to match you with others who'll be best able to understand you. No one can see this data.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        height: 1.25,
                      )),
                  const SizedBox(height: 32.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        textAlign: TextAlign.start,
                        "Where do you live?",
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w500,
                          fontSize: 17.5,
                          height: 1.25,
                        ),
                      )),
                  const SizedBox(height: 6.0),
                  CSCPicker(
                    onCountryChanged: (value) {
                      setState(() {
                        _country = value;
                      });
                    },
                    onStateChanged: (value) {
                      setState(() {
                        _state = value;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        _city = value;
                      });
                    },
                  ),
                  const SizedBox(height: 28.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Sex")),
                          const SizedBox(height: 4.0),
                          Row(children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: _hasChosenGender
                                      ? _isMale
                                          ? MaterialStateProperty.all<Color>(
                                              primaryColor)
                                          : MaterialStateProperty.all<Color>(
                                              Colors.white)
                                      : MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isMale = true;
                                    _hasChosenGender = true;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: Text("M",
                                      style: TextStyle(
                                          color: _hasChosenGender
                                              ? _isMale
                                                  ? Colors.white
                                                  : primaryColor
                                              : primaryColor)),
                                )),
                            const SizedBox(width: 8),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isMale = false;
                                    _hasChosenGender = true;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: _hasChosenGender
                                      ? _isMale
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.white)
                                          : MaterialStateProperty.all<Color>(
                                              primaryColor)
                                      : MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: Text("F",
                                      style: TextStyle(
                                          color: _hasChosenGender
                                              ? _isMale
                                                  ? primaryColor
                                                  : Colors.white
                                              : primaryColor)),
                                )),
                          ]),
                        ],
                      ),
                      const SizedBox(width: 24.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Age", style: TextStyle(fontSize: 12.0)),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60.0,
                            height: 48.0,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _ageController,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(width: 10.0),
                  const SizedBox(height: 28.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.start,
                      "Which of these conditions have you been diagnosed with?",
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w500,
                        fontSize: 17.5,
                        height: 1.25,
                      ),
                    ),
                  ),
                  MultiSelectDialogField(
                    items: conditions
                        .map((e) => MultiSelectItem(e, capitalize(e)))
                        .toList(),
                    listType: MultiSelectListType.CHIP,
                    onConfirm: (values) {
                      selectedConditions = values;
                    },
                  ),
                  const Spacer(),
                  primaryButton("Create my account",
                      icon: Icons.check,
                      action: () => {_createFirebaseAccount(context)})
                ],
              )),
    );
  }
// TODO: convert this to a firebase api call instead of using the firebase auth api
  void _createFirebaseAccount(context) async {
    setState(() {
      _isMakingAccount = true;
    });
    // get profile from dicebear

    final profileImagesRef =
        storageRef.child("profileImages").child("${widget.name}.png");

    // Avatar _avatar = DiceBearBuilder.withRandomSeed().build();
    // print('Got avatar from dicebear');
    // Uint8List? raw = await _avatar.asRawSvgBytes();

    // if (pngBase64 != null) {
    //   await profileImagesRef.putData(pngBase64);
    //   print('Uploaded profile image to firebase storage');
    // }
    // String profileUrl = await profileImagesRef.getDownloadURL();
    final data = {
      'isPremium': false,
      'sex': _isMale ? 'M' : 'F',
      'age': _ageController.text,
      'city': _city,
      'timeJoined': DateTime.now().toIso8601String(),
      'name': widget.name,
      'conditions': selectedConditions,
    };
    db.collection("users").add(data).then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      persistence.rememberLogin(prefs, firebaseUserId: value.id);
      setState(() {
        _isMakingAccount = false;
      });
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BottomTabController(prefs: prefs)));
    });

    //
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
