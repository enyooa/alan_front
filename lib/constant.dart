import 'package:flutter/material.dart';

const baseUrl = 'https://alantrade.kz/api/';
const basePhotoUrl = 'https://alantrade.kz/';

// Replace the old colors with the new ones you want
const primaryColor = Color(0xFF0ABCD7); // #0ABCD7
const accentColor  = Color(0xFF6CC6DA); // #6CC6DA

const backgroundColor = Color(0xFFF1F3F8);
const borderColor = Color(0xFFD1D9E6);
const unselectednavbar = Colors.grey;
const Color errorColor = Color(0xFFB00020);
const Color textColor = Colors.black87;

// Define text styles
const TextStyle headingStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w100,
  color: Colors.white,
);

const TextStyle titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w100,
  color: Colors.black,
);

const TextStyle subheadingStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

const TextStyle bodyTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: Colors.black,
);

const TextStyle captionStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w400,
  color: Colors.grey,
);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

const TextStyle formLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

// Table styles
const TextStyle tableHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle tableCellStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.normal,
  color: Colors.black87,
);

// Padding constants
const double horizontalPadding = 16.0;
const double verticalPadding = 12.0;
const EdgeInsets pagePadding = EdgeInsets.all(16.0);
const EdgeInsets elementPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);

// Border styles
const BorderSide tableBorderSide = BorderSide(color: borderColor, width: 1.0);

// Elevated Button style
final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);
