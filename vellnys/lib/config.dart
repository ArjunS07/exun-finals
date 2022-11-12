import 'package:flutter/material.dart';

Color primaryColor = Colors.blue.shade800;
Color secondaryColor = Colors.amber.shade100;
Color secondaryGray = Colors.grey.shade200;

TextStyle titleTS = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

Text title(String text) {
  return Text(text, style: titleTS);
}

TextStyle heading1TS = const TextStyle(
  color: Colors.black,
  fontSize: 36,
  fontWeight: FontWeight.bold,
);

Text heading1(String text) {
  return Text(text, style: heading1TS);
}

TextStyle heading2TS = const TextStyle(
  color: Colors.black,
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

Text heading2(String text) {
  return Text(text, style: heading2TS);
}

TextStyle bodyTS = const TextStyle(
  color: Colors.black,
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
);

Text body(String text) {
  return Text(text, style: bodyTS);
}

TextStyle descriptiveTS = TextStyle(
  color: Colors.grey.shade600,
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
);

Text descriptiveText(String text) {
  return Text(text, style: descriptiveTS);
}

ButtonStyle primaryButtonStyle = ButtonStyle(
  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
  textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  )),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(7.5),
    ),
  ),
);

primaryButton(String text, {icon, action}) {
  return ElevatedButton(
    style: primaryButtonStyle,
    onPressed: () {
      action();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          if (icon != null) const SizedBox(width: 16),
          if (icon != null) Icon(icon),
        ],
      ),
    ),
  );
}
