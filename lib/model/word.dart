import 'package:collection/collection.dart';
import 'package:eiken_grade_1/model/user.dart';

class Word {
  String? uuid;
  String category;
  String eng;
  String exEng;
  String exJap;
  String? exp;
  String id;
  String jap;
  String level;
  String mp3Eng;
  String mp3Ex;
  String mp3Jap;
  String no;
  String? pron;
  String pum;

  Word(
      {this.uuid,
      required this.category,
      required this.eng,
      required this.exEng,
      required this.exJap,
      this.exp,
      required this.id,
      required this.jap,
      required this.level,
      required this.mp3Eng,
      required this.mp3Ex,
      required this.mp3Jap,
      required this.no,
      this.pron,
      required this.pum});

  static Word fromJson(Map<String, dynamic> json) {
    return Word(
      category: json['category'],
      eng: json['eng'],
      exEng: json['ex_eng'],
      exJap: json['ex_jap'],
      exp: json['exp'] ?? '',
      id: json['id'],
      jap: json['jap'],
      level: json['level'] != '' ? json['level'] : 'Idioms',
      mp3Eng: json['mp3_eng'],
      mp3Ex: json['mp3_ex'],
      mp3Jap: json['mp3_jap'],
      no: json['no'],
      pron: json['pron'] ?? '',
      pum: json['pum'],
    );
  }

  String ipaPron(Map<String, String> symbols) {
    return symbols.entries.toList().reversed.fold(
        pron.toString(),
        (prev, e) =>
            prev.replaceAll(e.key, e.value).replaceAll(RegExp(r'<.*?>'), ''));
  }

  String toHtml(String property) {
    return property
        .replaceAll('s>', 'small>')
        .replaceAllMapped(RegExp(r'（(.*?)）'), (m) => ' (${m[1]}) ')
        .replaceAllMapped(RegExp(r'<r>(.*?)<rt>(.*?)<\/r>'),
            (m) => '<ruby>${m[1]}<rt>${m[2]}</rt></ruby>');
  }

  bool isState(String state, User user) {
    final word = user.words.firstWhereOrNull((word) => word['id'] == id);
    if (word == null) {
      return state == 'Not remembered';
    } else if (word['remembered']) {
      return state == 'Remembered';
    } else {
      return state == 'Forgot' || state == 'Not remembered';
    }
  }

  bool isToDisplay(String level, String state, User user) {
    if (this.level == level) {
      return state == 'All' ||
          ['Remembered', 'Forgot', 'Not remembered']
              .any((s) => state == s && isState(s, user));
    } else {
      return false;
    }
  }
}
