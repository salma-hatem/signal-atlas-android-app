import 'package:flutter/material.dart';

class MapFilters {
  static ColorFilter colorFilterForTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const ColorFilter.matrix([
        3, 0, 0, 0, 0,
        0, 3, 0, 0, 0,
        0, 0, 4, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    } else {
      return const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 2, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
  }
}