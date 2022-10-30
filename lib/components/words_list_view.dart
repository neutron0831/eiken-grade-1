import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:eiken_grade_1/model/configuration.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/pages/word_page.dart';
import 'package:eiken_grade_1/providers/symbols_provider.dart';
import 'package:eiken_grade_1/providers/words_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class WordsListView extends ConsumerWidget {
  final AudioPlayer audioPlayer;

  const WordsListView(this.audioPlayer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final words = ref.watch(wordsProvider);
    final symbols = ref.watch(symbolsProvider);
    final config = ref.watch(configurationProvider).configuration;

    ScrollController scrollController = ScrollController();

    return words.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Error: $err'),
        data: (words) {
          return DraggableScrollbar.semicircle(
            controller: scrollController,
            child: ListView.builder(
                controller: scrollController,
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return word.isToDisplay(config.level, config.state, user)
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
                                        (config.level != 'Idioms' ? 0.4 : 0.5),
                                    height: config.level != 'Idioms' ? 83 : 80,
                                    color: Colors.red[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(word.id),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(word.eng,
                                              style: TextStyle(
                                                  backgroundColor: word.isState(
                                                          'Remembered', user)
                                                      ? Colors.green[200]
                                                      : word.isState(
                                                              'Forgot', user)
                                                          ? Colors.red[200]
                                                          : Colors.transparent,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        symbols.when(
                                            loading: () =>
                                                const CircularProgressIndicator(),
                                            error: (err, stack) =>
                                                Text('Error: $err'),
                                            data: (symbols) {
                                              return config.level != 'Idioms'
                                                  ? Text(word.ipaPron(symbols))
                                                  : Container();
                                            }),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (config.listenEng) {
                                      await audioPlayer.stop();
                                      await audioPlayer.setAsset(
                                          'assets/mp3/${word.mp3Eng}.mp3');
                                      await audioPlayer.play();
                                      if (config.listenJap) {
                                        await audioPlayer.setAsset(
                                            'assets/mp3/${word.mp3Jap}.mp3');
                                        await audioPlayer.play();
                                      }
                                    }
                                    await ref
                                        .read(userProvider.notifier)
                                        .setWord(word.id);
                                  }),
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => WordPage(
                                                  user, word, audioPlayer)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 80,
                                      child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Html(
                                                  data: word.toHtml(word.jap),
                                                  style: {
                                                    '*': Style(
                                                        margin: EdgeInsets.zero,
                                                        lineHeight:
                                                            LineHeight.rem(word
                                                                    .jap
                                                                    .contains(
                                                                        '<rt>')
                                                                ? 1.5
                                                                : 1)),
                                                    'em': Style(
                                                        color: word.isState(
                                                                'Remembered',
                                                                user)
                                                            ? Colors.transparent
                                                            : Colors.redAccent,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontWeight:
                                                            FontWeight.bold)
                                                  }),
                                            ],
                                          )),
                                    )),
                              ),
                            ],
                          ),
                        )
                      : Container();
                }),
          );
        });
  }
}
