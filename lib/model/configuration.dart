import 'package:eiken_grade_1/utils/authentication.dart';
import 'package:eiken_grade_1/utils/firebase.dart';
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
      this.states = const ['Not remembered', 'Forgot', 'Remembered', 'All'],
      required this.state,
      required this.listenEng,
      required this.listenJap,
      required this.playSpeed});
}

class ConfigurationNotifier extends ChangeNotifier {
  final configuration = Configuration(
      level: 'A',
      state: 'All',
      listenEng: true,
      listenJap: true,
      playSpeed: 1.0);

  void setConfiguration(Configuration conf) {
    configuration.level = conf.level;
    configuration.state = conf.state;
    configuration.listenEng = conf.listenEng;
    configuration.listenJap = conf.listenJap;
    configuration.playSpeed = conf.playSpeed;
    notifyListeners();
  }

  void setLevel(String id, String level) {
    configuration.level = level;
    Firestore.updateConfiguration(id, configuration);
    notifyListeners();
  }

  void setState(String id, String state) {
    configuration.state = state;
    Firestore.updateConfiguration(id, configuration);
    notifyListeners();
  }

  void toggleListenEng(String id, bool value) {
    configuration.listenEng = value;
    Firestore.updateConfiguration(id, configuration);
    notifyListeners();
  }

  void toggleListenJap(String id, bool value) {
    configuration.listenJap = value;
    Firestore.updateConfiguration(id, configuration);
    notifyListeners();
  }

  void setPlaySpeed(String id, double speed) {
    configuration.playSpeed = speed;
    Firestore.updateConfiguration(id, configuration);
    notifyListeners();
  }
}

final configurationProvider = ChangeNotifierProvider<ConfigurationNotifier>(
    (ref) => ConfigurationNotifier());
