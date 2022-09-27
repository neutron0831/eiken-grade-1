import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Configuration {
  final List<String>? levels;
  String level;
  final List<String>? states;
  String state;
  bool listenEng;
  bool listenJap;
  double playSpeed;

  Configuration(
      {this.levels = const ['A', 'B', 'C', 'Idioms'],
      required this.level,
      this.states = const ['Remembered', 'Forgot', 'Not remembered', 'All'],
      required this.state,
      required this.listenEng,
      required this.listenJap,
      required this.playSpeed});
}

class ConfigurationNotifier extends ChangeNotifier {
  final configuration = Configuration(
      level: 'A',
      state: 'Not remembered',
      listenEng: true,
      listenJap: true,
      playSpeed: 1.0);

  void setLevel(String level) {
    configuration.level = level;
    notifyListeners();
  }

  void setState(String state) {
    configuration.state = state;
    notifyListeners();
  }

  void toggleListenEng(bool value) {
    configuration.listenEng = value;
    notifyListeners();
  }

  void toggleListenJap(bool value) {
    configuration.listenJap = value;
    notifyListeners();
  }

  void setPlaySpeed(double speed) {
    configuration.playSpeed = speed;
    notifyListeners();
  }
}

final configurationProvider = ChangeNotifierProvider<ConfigurationNotifier>(
    (ref) => ConfigurationNotifier());
