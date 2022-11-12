import 'package:flutter/gestures.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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
      padding: const EdgeInsets.only(
          top: 64.0, left: 16.0, right: 16.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(children: [
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
              Spacer(),
              primaryButton('Get started',
                  action: () => {
                        print('Calling function...'),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NameGenerator()))
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
  final TextEditingController _ageController = TextEditingController();

  bool _isMale = false;
  bool _hasChosenGender = false;

  int _selectedAge = 0;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
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
                          alignment: Alignment.centerLeft, child: Text("Sex")),
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
                  icon: Icons.check, action: () {})
            ],
          )),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
