import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BrdyTextTheme {
  static TextTheme get textTheme => TextTheme(
    displaySmall: _jetBrains(28, FontWeight.w700, 1.2),  // displayNumeric
    bodyMedium:   _jetBrains(16, FontWeight.w400, 1.5),  // bodyNumeric
    labelLarge:   _barlow(18, FontWeight.w700, 1.2),     // buttons, section headings
    bodySmall:    _barlow(14, FontWeight.w400, 1.5),     // labels, helper text
  );

  static TextStyle _jetBrains(double size, FontWeight weight, double height) =>
      GoogleFonts.sometypeMono(fontSize: size, fontWeight: weight, height: height);

  static TextStyle _barlow(double size, FontWeight weight, double height) =>
      GoogleFonts.sometypeMono(fontSize: size, fontWeight: weight, height: height);
}
