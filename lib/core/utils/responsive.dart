import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double cardPadding(BuildContext context) =>
      isTablet(context) ? 28.0 : 20.0;

  static int productGridColumns(BuildContext context) =>
      isTablet(context) ? 3 : 2;
}
