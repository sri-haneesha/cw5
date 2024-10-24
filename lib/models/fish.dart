import 'package:flutter/material.dart';

class Fish {
  Color color;
  double speed;
  Offset position;
  Offset direction;
  double size;

  Fish({
    required this.color,
    required this.speed,
    required this.position,
    required this.direction,
    this.size = 20,
  });
}
