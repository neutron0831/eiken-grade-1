import 'package:eiken_grade_1/model/word.dart';
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
  final user = User(id: '', username: 'NEUTRON', words: []);

  UserNotifier() {
    Firestore.getUser(user.username).then((u) {
      user.id = u['id']!;
      Firestore.getWords(user.id).then((words) {
        user.words = words;
        notifyListeners();
      });
    });
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
    ChangeNotifierProvider<UserNotifier>((ref) => UserNotifier());
