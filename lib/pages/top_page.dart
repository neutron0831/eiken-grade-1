import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:eiken_grade_1/components/progress_chart.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/pages/word_page.dart';
import 'package:eiken_grade_1/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:just_audio/just_audio.dart';

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
  static bool listenOnTap = true;
  static bool listenJapanese = true;
  static double playSpeed = 1.0;

  AudioPlayer audioPlayer = AudioPlayer();
  ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isWord(String wordId, String status) {
    final words = user.words!.where((word) => word['id'] == wordId);
    if (status == 'Remembered') {
      return words.where((word) => word['remembered']).isNotEmpty;
    } else if (status == 'Forgot') {
      return words.where((word) => !word['remembered']).isNotEmpty;
    } else if (status == 'Not remembered') {
      return words.isEmpty;
    } else {
      return true;
    }
  }

  bool isWordToDisplay(Word word) {
    return levelToDisplay == word.level &&
        (statusToDisplay == 'All' ||
            statusToDisplay == 'Remembered' && isWord(word.id, 'Remembered') ||
            statusToDisplay == 'Forgot' && isWord(word.id, 'Forgot') ||
            statusToDisplay == 'Not remembered' &&
                isWord(word.id, 'Not remembered'));
  }

  int wordsNum(String level, String status) {
    return words.isNotEmpty
        ? words
            .where((word) => word.level == level && isWord(word.id, status))
            .length
        : 1;
  }

  Future<void> _fetchUserData() async {
    await Firestore.getUser(user.username).then((u) {
      user.id = u['id'].toString();
    });
    await Firestore.getWords(user.id).then((words) => user.words = words);
  }

  Future<void> _setupSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData().whenComplete(() => setState(() {}));
    _setupSession();
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
        ]),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          if (!snapshot.hasData) {
            return const Center(child: Text('単語データがありません'));
          }
          words = List<Word>.from(
              jsonDecode((snapshot.data! as List)[0].toString())
                  .map((word) => Word.fromJSON(word)));
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
                  return isWordToDisplay(words[index])
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
                                    height: 80,
                                    color: Colors.red[100],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(words[index].id),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(words[index].eng,
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
                                        ),
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
                                  onTap: () async {
                                    if (listenOnTap) {
                                      await audioPlayer.stop();
                                      await audioPlayer.setAsset(
                                          'assets/mp3/${words[index].mp3Eng}.mp3');
                                      await audioPlayer.play();
                                      if (listenJapanese) {
                                        await audioPlayer.setAsset(
                                            'assets/mp3/${words[index].mp3Jap}.mp3');
                                        await audioPlayer.play();
                                      }
                                    }
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
                                  height: 80,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: GestureDetector(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Html(
                                                data: words[index]
                                                    .jap
                                                    .replaceAll('s>', 'small>')
                                                    .replaceAllMapped(
                                                        RegExp(r'（(.*?)）'),
                                                        (m) => ' (${m[1]}) ')
                                                    .replaceAllMapped(
                                                        RegExp(
                                                            r'<r>(.*?)<rt>(.*?)<\/r>'),
                                                        (m) =>
                                                            '<ruby>${m[1]}<rt>${m[2]}</rt></ruby>'),
                                                style: {
                                                  '*': Style(
                                                      margin: EdgeInsets.zero,
                                                      lineHeight: LineHeight
                                                          .rem(words[index]
                                                                  .jap
                                                                  .contains(
                                                                      '<rt>')
                                                              ? 1.5
                                                              : 1)),
                                                  'em': Style(
                                                      color: isWord(
                                                              words[index].id,
                                                              'Remembered')
                                                          ? Colors.transparent
                                                          : Colors.redAccent,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontWeight:
                                                          FontWeight.bold)
                                                }),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WordPage(
                                                          user,
                                                          words[index],
                                                          symbols,
                                                          audioPlayer)));
                                        }),
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
          appBar: AppBar(title: const Text('Menu')),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 21),
                child: Text('Settings', style: TextStyle(fontSize: 21)),
              ),
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
              ),
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Listen on Tap:')),
                    SizedBox(
                        width: 26, child: Text(listenOnTap ? 'ON' : 'OFF')),
                    Switch(
                      value: listenOnTap,
                      onChanged: (bool? value) {
                        setState(() {
                          listenOnTap = value!;
                          if (!listenOnTap) {
                            listenJapanese = false;
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: Row(
                  children: [
                    const SizedBox(
                        width: 120, child: Text('Include Japanese:')),
                    SizedBox(
                        width: 26, child: Text(listenJapanese ? 'ON ' : 'OFF')),
                    Switch(
                      value: listenJapanese,
                      onChanged: listenOnTap
                          ? (bool? value) {
                              setState(() {
                                listenJapanese = value!;
                              });
                            }
                          : null,
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Play Speed: x$playSpeed'),
                    SliderTheme(
                      data: const SliderThemeData(
                          activeTickMarkColor: Colors.green,
                          inactiveTickMarkColor: Colors.transparent),
                      child: Slider(
                          value: playSpeed,
                          min: 0.5,
                          max: 4.0,
                          divisions: 7,
                          onChanged: (double? value) async {
                            await audioPlayer.setSpeed(value!);
                            setState(() {
                              playSpeed = value;
                            });
                          }),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 21),
                child: Text('Progress', style: TextStyle(fontSize: 21)),
              ),
              Column(children: [
                for (String level in levels)
                  ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${level != 'Idioms' ? 'Level ' : ''}$level: ${wordsNum(level, 'Remembered')}/${words.where((word) => word.level == level).length}',
                        ),
                        LinearProgressIndicator(
                          value: wordsNum(level, 'Remembered') /
                              wordsNum(level, 'All'),
                        ),
                      ],
                    ),
                  ),
              ]),
              Container(
                padding: const EdgeInsets.only(top: 14, left: 14),
                height: 200,
                child: ProgressChart(user.words!, animate: false),
              ),
            ]),
          ),
        )),
      ),
    );
  }
}
