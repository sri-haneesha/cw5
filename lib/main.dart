import 'package:flutter/material.dart';
import 'dart:math';
import 'package:virtual_aquarium/models/fish.dart';
import 'widgets/aquarium.dart';
import 'services/storage_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  double speed = 2.0;
  Color selectedColor = Colors.blue;
  int maxFishCount = 10;
  bool enableCollision = true;

  final List<Color> fishColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved settings from SQLite
    final settings = await StorageService().loadSettings();
    setState(() {
      fishList = settings['fishList'] ?? [];
      speed = settings['speed'] ?? 2.0;
      selectedColor = settings['color'] ?? Colors.blue;
      enableCollision = settings['collision'] ?? true;
    });
  }

  void _addFish() {
    if (fishList.length < maxFishCount) {
      setState(() {
        fishList.add(Fish(
          color: selectedColor,
          speed: speed,
          position:
              Offset(Random().nextDouble() * 280, Random().nextDouble() * 280),
          direction: Offset(
              Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max fish count reached!')),
      );
    }
  }

  void _saveSettings() async {
    // Save settings to local storage
    await StorageService()
        .saveSettings(fishList, speed, selectedColor, enableCollision);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Aquarium(
                fishList: fishList,
                speed: speed,
                enableCollision: enableCollision),
          ),
          Slider(
            value: speed,
            min: 0.5,
            max: 5.0,
            onChanged: (value) {
              setState(() {
                speed = value;
                for (var fish in fishList) {
                  fish.speed = speed;
                }
              });
            },
          ),
          DropdownButton<Color>(
            value: selectedColor,
            onChanged: (Color? newValue) {
              setState(() {
                selectedColor = newValue!;
              });
            },
            items: fishColors.map((Color color) {
              return DropdownMenuItem<Color>(
                value: color,
                child: Container(
                  width: 20,
                  height: 20,
                  color: color,
                ),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: _addFish,
            child: Text('Add Fish'),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text('Save Settings'),
          ),
          SwitchListTile(
            title: Text('Enable Collision'),
            value: enableCollision,
            onChanged: (bool value) {
              setState(() {
                enableCollision = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
