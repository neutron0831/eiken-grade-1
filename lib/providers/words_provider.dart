import 'dart:convert';

import 'package:eiken_grade_1/model/word.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wordsProvider = FutureProvider<List<Word>>((ref) async {
  final words = List<Word>.from(json
      .decode(await rootBundle.loadString('assets/words.json'))
      .map((word) => Word.fromJson(word)));
  return words;
});
