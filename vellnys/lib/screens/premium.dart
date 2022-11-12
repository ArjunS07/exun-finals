import 'package:flutter/material.dart';
import 'package:loqui/config.dart';

class Premium extends StatefulWidget {
  const Premium({Key? key}) : super(key: key);

  @override
  _PremiumState createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Premium'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.only(
            top: 32.0, left: 24.0, right: 24.0, bottom: 32.0),
        child: Column(
          children: [
            Text("Take your care to the next level with", style: bodyTS),
            const SizedBox(height: 5.0),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "LoQui",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  ),
                  const SizedBox(width: 7.0),
                  Text(
                    textAlign: TextAlign.left,
                    "Premium",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold),
                  )
                ]),
            const SizedBox(height: 24.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.left,
                "Starting 5.99/month, you get...",
                style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: primaryColor),
                      left: BorderSide(color: primaryColor),
                      right: BorderSide(color: primaryColor),
                      bottom: BorderSide(color: primaryColor),
                    )),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: (Row(
                      children: [
                        Column(children: const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'More Chats',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Open unlimited active chat rooms, above the limit of 3.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                ),
                              )),
                        ])
                      ],
                    ))),
              ),
              const SizedBox(height: 24.0),
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: primaryColor),
                      left: BorderSide(color: primaryColor),
                      right: BorderSide(color: primaryColor),
                      bottom: BorderSide(color: primaryColor),
                    )),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: (Column(
                      children: const [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Unlimited voice messages',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Send voice notes with no time limit.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0),
                            ))
                      ],
                    ))),
              ),
            ]),
            const SizedBox(height: 24.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.left,
                "Starting 9.99/month, you cal also ...",
                style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: primaryColor),
                      left: BorderSide(color: primaryColor),
                      right: BorderSide(color: primaryColor),
                      bottom: BorderSide(color: primaryColor),
                    )),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: (Column(
                      children: const [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Connect With Experts',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Match with verified professionals within Vellnys and connect anonymously ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0),
                            ))
                      ],
                    ))),
              ),
            ]),
            const Spacer(),
            primaryButton('Purchase Now')
          ],
        ),
      ),
    );
  }
}
