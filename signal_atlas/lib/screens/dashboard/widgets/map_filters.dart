import 'package:flutter/material.dart';

class MapFilters {
  static ColorFilter colorFilterForTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const ColorFilter.matrix([
        3.5, 0, 0, 0, 10,
        0, 3.5, 0, 0, 10,
        0, 0, 4.5, 0, 10,
        0, 0, 0, 1, 0,
      ]);
    } else {
      return const ColorFilter.matrix([
        2, 0, 0, 0, -256,
        0, 2, 0, 0, -256,
        0, 0, 3, 0, -256,
        0, 0, 0, 1, 0,
      ]);
    }
  }
}