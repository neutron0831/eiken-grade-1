import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  static User user = User(id: '', username: 'NEUTRON', words: []);
  static List<Word> words = [];
  static Map<String, String> symbols = {};
  static List<String> levels = ['A', 'B', 'C', 'Idioms'];
  static String levelToDisplay = 'A';
  static List<String> status = [
    'Not remembered',
    'Forgot',
    'Remembered',
    'All'
  ];
  static String statusToDisplay = 'Not remembered';

  ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isWord(String wordId, String status) {
    final words = user.words!.where((word) => word['id'] == wordId);
    if (status == 'Remembered') {
      return words.where((word) => word['remembered']).isNotEmpty;
    } else if (status == 'Forgot') {
      return words.where((word) => !word['remembered']).isNotEmpty;
    } else if (status == 'Not remembered') {
      return words.where((word) => word['remembered']).isEmpty;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Eiken Grade 1'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          DefaultAssetBundle.of(context).loadString('assets/words.json'),
          DefaultAssetBundle.of(context).loadString('assets/symbols.json'),
          Firestore.getUser(user.username).then((u) {
            user.id = u['id'].toString();
            Firestore.getWords(user.id).then((words) => user.words = words);
          }),
        ]),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          if (!snapshot.hasData) {
            return const Center(child: Text('単語データがありません'));
          }
          words =
              List<Word>.from(jsonDecode((snapshot.data! as List)[0].toString())
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
                  .where((word) => word.level == levelToDisplay));
          List<String> ipaSymbols = List<String>.from(
              jsonDecode((snapshot.data! as List)[1].toString())
                  .map((symbol) => symbol['ipa_symbol']));
          List<String> obsSymbols = List<String>.from(
              jsonDecode((snapshot.data! as List)[1].toString())
                  .map((symbol) => symbol['obs_symbol']));
          symbols = Map.fromIterables(obsSymbols, ipaSymbols);
          return DraggableScrollbar.semicircle(
            controller: scrollController,
            child: ListView.builder(
                controller: scrollController,
                itemCount: words.length,
                itemBuilder: (context, index) {
                  return statusToDisplay == 'All' ||
                          statusToDisplay == 'Remembered' &&
                              isWord(words[index].id, 'Remembered') ||
                          statusToDisplay == 'Forgot' &&
                              isWord(words[index].id, 'Forgot') ||
                          statusToDisplay == 'Not remembered' &&
                              isWord(words[index].id, 'Not remembered')
                      ? Container(
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide())),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: MediaQuery.of(context).size.width *
                                        (levelToDisplay != 'Idioms'
                                            ? 0.4
                                            : 0.5),
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
                                                  backgroundColor: isWord(
                                                          words[index].id,
                                                          'Remembered')
                                                      ? Colors.green[200]
                                                      : isWord(words[index].id,
                                                              'Forgot')
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
                                                      .replaceAll(
                                                          e.key, e.value)
                                                      .replaceAll(
                                                          RegExp(r'<.*?>'),
                                                          '')))
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    int i = user.words!.indexWhere((word) =>
                                        word['id'] == words[index].id);
                                    if (i != -1) {
                                      user.words![i]['remembered'] =
                                          !user.words![i]['remembered'];
                                      final word = user.words![i];
                                      await Firestore.updateWord(user.id, word);
                                    } else {
                                      final word = {
                                        'id': words[index].id,
                                        'remembered': true,
                                        'updatedAt': DateTime.now()
                                      };
                                      user.words!.add(word);
                                      await Firestore.addWord(user.id, word);
                                    }
                                    final updatedWords =
                                        await Firestore.getWords(user.id);
                                    setState(() {
                                      user.words = updatedWords;
                                    });
                                  }),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        child: Text(
                                            isWord(words[index].id,
                                                    'Not remembered')
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
                        )
                      : Container();
                }),
          );
        },
      ),
      endDrawer: SafeArea(
        child: Drawer(
            child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: Row(
                  children: [
                    const SizedBox(width: 50, child: Text('Level:')),
                    DropdownButton(
                      value: levelToDisplay,
                      items: levels
                          .map((level) => DropdownMenuItem(
                              value: level, child: Text(level)))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          levelToDisplay = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: Row(
                  children: [
                    const SizedBox(width: 50, child: Text('Status:')),
                    DropdownButton(
                      value: statusToDisplay,
                      items: status
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          statusToDisplay = value!;
                        });
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
