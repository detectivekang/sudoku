import 'package:flutter/material.dart';

class ResponsiveSize {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getSudokuGridSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      return screenWidth * 0.9;
    } else {
      return screenHeight * 0.9;
    }
  }

  static double getNumberPadButtonSize(BuildContext context) {
    final gridSize = getSudokuGridSize(context);
    return gridSize / 9;
  }
} 