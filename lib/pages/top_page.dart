import 'dart:convert';

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
  User user = User(id: const Uuid().v4(), username: 'NEUTRON', words: []);
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
            DefaultAssetBundle.of(context).loadString('assets/words.json'),
            DefaultAssetBundle.of(context).loadString('assets/symbols.json')
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData) {
              return const Center(child: Text('単語データがありません'));
            }
            words = List<Word>.from(
                jsonDecode((snapshot.data! as List)[0].toString())
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
                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide())),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.4,
                            color: const Color(0xfffbd6e7),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(words[index].id),
                                  Text(words[index].eng,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                  Text(symbols.entries.fold(
                                      words[index].pron.toString(),
                                      (prev, e) => prev
                                          .replaceAll(e.key, e.value)
                                          .replaceAll(RegExp(r'<.*?>'), '')))
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    child: Text(
                                        words[index]
                                            .jap
                                            .replaceAll(RegExp(r'<.*?>'), ''),
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
