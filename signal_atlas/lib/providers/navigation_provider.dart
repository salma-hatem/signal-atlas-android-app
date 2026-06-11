import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _index = 0;
  PageController? _pageController;

  int get index => _index;

  void attachController(PageController controller) {
    _pageController = controller;
  }

  void navigateTo(int index) {
    _index = index;
    notifyListeners();
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }
}
