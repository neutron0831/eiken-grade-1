import 'package:eiken_grade_1/model/configuration.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/utils/authentication.dart';
import 'package:eiken_grade_1/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  String id;
  String username;
  List words;

  User({required this.id, required this.username, required this.words});

  int wordsNum(List<Word> words, String level, String state) {
    if (state == 'All') {
      return words.where((word) => word.level == level).length;
    }
    return words
        .where((word) => word.level == level && word.isState(state, this))
        .length;
  }
}

class UserNotifier extends ChangeNotifier {
  final user = User(id: '', username: '', words: []);

  UserNotifier(ref) {
    setUser(ref);
  }

  void setUser(ref) {
    final currentFirebaseUser = ref.read(authProvider).currentFirebaseUser;
    Firestore.getUser(currentFirebaseUser.uid).then((u) {
      user.id = u['id']!;
      user.username = u['username']!;
      final conf = Configuration(
          level: u['level'],
          state: u['state'],
          listenEng: u['listenEng'],
          listenJap: u['listenJap'],
          playSpeed: u['playSpeed']);
      ref.read(configurationProvider).setConfiguration(conf);
      Firestore.getWords(user.id).then((words) {
        user.words = words;
        notifyListeners();
      });
    }).catchError((e) => Firestore.addUser({
          'id': currentFirebaseUser.uid,
          'username': currentFirebaseUser.displayName
        }, ref.read(configurationProvider).configuration)
            .then((_) {
          user.id = currentFirebaseUser.uid;
          user.words = [];
          notifyListeners();
        }));
  }

  void setId(String id) {
    user.id = id;
    notifyListeners();
  }

  void setWords(List words) {
    user.words = words;
    notifyListeners();
  }

  Future<void> setWord(String id) async {
    final index = user.words.indexWhere((word) => word['id'] == id);
    final word = {
      'id': id,
      'remembered': index != -1 ? !user.words[index]['remembered'] : true,
      'updatedAt': DateTime.now()
    };
    if (index != -1) {
      user.words[index] = word;
      await Firestore.updateWord(user.id, word);
    } else {
      user.words.add(word);
      await Firestore.addWord(user.id, word);
    }
    notifyListeners();
  }
}

final userProvider =
    ChangeNotifierProvider<UserNotifier>((ref) => UserNotifier(ref));
