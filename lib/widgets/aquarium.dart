import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';

class Aquarium extends StatefulWidget {
  final List<Fish> fishList;
  final double speed;
  final bool enableCollision;

  Aquarium(
      {required this.fishList,
      required this.speed,
      required this.enableCollision});

  @override
  _AquariumState createState() => _AquariumState();
}

class _AquariumState extends State<Aquarium>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFishPosition() {
    for (var fish in widget.fishList) {
      setState(() {
        // Move the fish according to its speed
        fish.position += fish.direction * fish.speed;

        // Boundary collision detection (change direction, maintain speed)
        if (fish.position.dx <= 0 || fish.position.dx >= 300 - fish.size) {
          fish.direction = Offset(-fish.direction.dx,
              fish.direction.dy); // Reverse horizontal direction
        }
        if (fish.position.dy <= 0 || fish.position.dy >= 300 - fish.size) {
          fish.direction = Offset(fish.direction.dx,
              -fish.direction.dy); // Reverse vertical direction
        }

        // Handle fish collision based on toggle
        if (widget.enableCollision) {
          for (var otherFish in widget.fishList) {
            if (fish != otherFish &&
                (fish.position - otherFish.position).distance < fish.size) {
              // Change direction and color on collision
              fish.direction = Offset(-fish.direction.dx, -fish.direction.dy);
              fish.color =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)];
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      _updateFishPosition();
    });

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        children: widget.fishList.map((fish) {
          return Positioned(
            left: fish.position.dx,
            top: fish.position.dy,
            child: Container(
              width: fish.size,
              height: fish.size,
              decoration: BoxDecoration(
                color: fish.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
