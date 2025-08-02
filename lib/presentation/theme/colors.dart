import 'package:flutter/material.dart';

// ignore: camel_case_types
class clsColors {
  /// The main background color of the app.
  /// HEX: #0D0F20
  static const Color background = Color(0xFF0D0F20);

  /// The background color for cards, input fields, and list items.
  /// HEX: #1C1F37
  static const Color cardBackground = Color(0xFF1C1F37);

  /// The primary text color, used for titles and important information.
  /// HEX: #FFFFFF
  static const Color primaryText = Color(0xFFFFFFFF);

  /// The secondary text color, used for placeholders, subtitles, and less important info.
  /// Also used for the "Expired" status.
  /// HEX: #8A91B4
  static const Color secondaryText = Color(0xFF8A91B4);

  /// The color for success indicators like checkmarks and the "Active" status.
  /// HEX: #34C79B
  static const Color successGreen = Color(0xFF34C79B);
  
  /// The color for tappable links like "View QR".
  /// HEX: #4A90E2
  static const Color linkBlue = Color(0xFF4A90E2);

  /// The starting color (purple/blue) for gradients on buttons.
  /// HEX: #6A49E3
  static const Color gradientStart = Color(0xFF6A49E3);

  /// The ending color (pink/orange) for gradients on buttons.
  /// HEX: #F37959
  static const Color gradientEnd = Color(0xFFF37959);

  static const Color errorRed = Color(0xFFFF4C4C);
  /// A pre-defined gradient using the start and end colors for convenience.
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}