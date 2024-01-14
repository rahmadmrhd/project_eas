import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  bool selected = false;
  Widget? screen;

  MenuItem({
    required this.title,
    required this.icon,
    this.screen,
  });
}
