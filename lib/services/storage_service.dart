import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:virtual_aquarium/models/fish.dart';

class StorageService {
  Future<Database> _openDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'aquarium_settings.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, fishCount INTEGER, speed REAL, color TEXT, collision INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> saveSettings(List<Fish> fishList, double speed, Color color,
      bool collisionEnabled) async {
    final db = await _openDB();

    String colorString = color.toString();

    await db.insert(
      'settings',
      {
        'fishCount': fishList.length,
        'speed': speed,
        'color': colorString,
        'collision': collisionEnabled ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final db = await _openDB();
    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty) {
      return {
        'fishCount': maps.first['fishCount'],
        'speed': maps.first['speed'],
        'color': _parseColor(maps.first['color']),
        'collision': maps.first['collision'] == 1,
      };
    } else {
      return {
        'fishCount': 0,
        'speed': 2.0,
        'color': Colors.blue,
        'collision': true,
      };
    }
  }

  Color _parseColor(String colorString) {
    switch (colorString) {
      case 'Color(0xff2196f3)': // Colors.blue
        return Colors.blue;
      case 'Color(0xfff44336)': // Colors.red
        return Colors.red;
      case 'Color(0xff4caf50)': // Colors.green
        return Colors.green;
      case 'Color(0xffffeb3b)': // Colors.yellow
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }
}
