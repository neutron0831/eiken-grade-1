import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  // Future users = FirebaseFirestore.instance.collection('users').get();
  User user = User(id: '', username: 'NEUTRON', words: []);
  List<Word> words = [];
  List<String> levels = ['A', 'B', 'C', 'Idioms'];
  Map<String, String> symbols = {};
  String level = 'A';

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Eiken Grade 1'),
          actions: [
            Row(
              children: [
                const Text('Level:'),
                const SizedBox(width: 10),
                Theme(
                  data: Theme.of(context).copyWith(canvasColor: Colors.green),
                  child: DropdownButton(
                    value: level,
                    items: levels
                        .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level,
                                style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        level = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        body: FutureBuilder(
          future: Future.wait([
            FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: user.username)
                .get(),
            DefaultAssetBundle.of(context).loadString('assets/words.json'),
            DefaultAssetBundle.of(context).loadString('assets/symbols.json')
          ]),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (!snapshot.hasData) {
              return const Center(child: Text('単語データがありません'));
            }
            user.id = (snapshot.data! as List)[0].docs[0].id;
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .collection('words')
                .get()
                .then((snapshot) => {
                      for (final word in snapshot.docs)
                        {
                          user.words!.add({
                            'id': word['id'],
                            'remembered': word['remembered'],
                            'updatedAt': word['updated_at']
                          })
                        }
                    });
            words = List<Word>.from(
                jsonDecode((snapshot.data! as List)[1].toString())
                    .map((word) => Word(
                          category: word['category'],
                          eng: word['eng'],
                          exEng: word['ex_eng'],
                          exJap: word['ex_jap'],
                          exp: word['exp'] ?? '',
                          id: word['id'],
                          jap: word['jap'],
                          level: word['level'] != '' ? word['level'] : 'Idioms',
                          mp3Eng: word['mp3_eng'],
                          mp3Ex: word['mp3_ex'],
                          mp3Jap: word['mp3_jap'],
                          no: word['no'],
                          pron: word['pron'] ?? '',
                          pum: word['pum'],
                        ))
                    .where((word) => word.level == level));
            List<String> ipaSymbols = List<String>.from(
                jsonDecode((snapshot.data! as List)[2].toString())
                    .map((symbol) => symbol['ipa_symbol']));
            List<String> obsSymbols = List<String>.from(
                jsonDecode((snapshot.data! as List)[2].toString())
                    .map((symbol) => symbol['obs_symbol']));
            symbols = Map.fromIterables(obsSymbols, ipaSymbols);
            return DraggableScrollbar.semicircle(
              controller: scrollController,
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide())),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width *
                                    (level != 'Idioms' ? 0.4 : 0.5),
                                color: const Color(0xfffbd6e7),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(words[index].id),
                                      Text(words[index].eng,
                                          style: TextStyle(
                                              backgroundColor: user.words!
                                                      .where((word) =>
                                                          word['id'] ==
                                                              words[index].id &&
                                                          word['remembered'])
                                                      .isNotEmpty
                                                  ? Colors.green[200]
                                                  : user.words!
                                                          .where((word) =>
                                                              word['id'] ==
                                                                  words[index]
                                                                      .id &&
                                                              !word[
                                                                  'remembered'])
                                                          .isNotEmpty
                                                      ? Colors.red[200]
                                                      : Colors.transparent,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      Text(symbols.entries
                                          .toList()
                                          .reversed
                                          .fold(
                                              words[index].pron.toString(),
                                              (prev, e) => prev
                                                  .replaceAll(e.key, e.value)
                                                  .replaceAll(
                                                      RegExp(r'<.*?>'), '')))
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () async {
                                int i = user.words!.indexWhere(
                                    (word) => word['id'] == words[index].id);
                                if (i != -1) {
                                  user.words![i]['remembered'] =
                                      !user.words![i]['remembered'];
                                  final word = user.words![i];
                                  final wordId = (await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(user.id)
                                          .collection('words')
                                          .where('id', isEqualTo: word['id'])
                                          .get())
                                      .docs[0]
                                      .id;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .collection('words')
                                      .doc(wordId)
                                      .update({
                                    'id': word['id'],
                                    'remembered': word['remembered'],
                                    'updated_at': Timestamp.now()
                                  });
                                } else {
                                  final word = {
                                    'id': words[index].id,
                                    'remembered': true,
                                    'updatedAt': DateTime.now()
                                  };
                                  user.words!.add(word);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .collection('words')
                                      .add({
                                    'id': word['id'],
                                    'remembered': word['remembered'],
                                    'updated_at': word['updatedAt']
                                  });
                                }
                                final updatedWords = (await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(user.id)
                                        .collection('words')
                                        .get())
                                    .docs;
                                setState(() {
                                  user.words = [];
                                  for (final word in updatedWords) {
                                    user.words!.add({
                                      'id': word['id'],
                                      'remembered': word['remembered'],
                                      'updatedAt': word['updated_at']
                                    });
                                  }
                                });
                              }),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    child: Text(
                                        user.words!
                                                .where((word) =>
                                                    word['id'] ==
                                                        words[index].id &&
                                                    word['remembered'])
                                                .isEmpty
                                            ? words[index].jap.replaceAll(
                                                RegExp(r'<.*?>'), '')
                                            : '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            );
          },
        ));
  }
}
