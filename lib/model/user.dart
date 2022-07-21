import 'package:collection/collection.dart';
import 'package:eiken_grade_1/model/word.dart';

class User {
  String id;
  String username;
  List words;

  User({required this.id, required this.username, required this.words});

  bool isWord(String wordId, String status) {
    final word = words.firstWhereOrNull((word) => word['id'] == wordId);
    if (word == null) {
      return status == 'Not remembered';
    } else if (word['remembered']) {
      return status == 'Remembered';
    } else {
      return status == 'Forgot' || status == 'Not remembered';
    }
  }

  bool isWordToDisplay(Word word, String level, String status) {
    if (level == word.level) {
      return status == 'All' ||
          ['Remembered', 'Forgot', 'Not remembered']
              .any((s) => status == s && isWord(word.id, s));
    } else {
      return false;
    }
  }

  int wordsNum(String level, String status) {
    if (status == 'All') return words.length;
    return words
        .where((word) => word['level'] == level && isWord(word['id'], status))
        .length;
  }
}
