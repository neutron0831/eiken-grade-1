import 'package:badges/badges.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/providers/symbols_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

class WordPage extends ConsumerWidget {
  final User user;
  final Word word;
  final AudioPlayer audioPlayer;

  const WordPage(this.user, this.word, this.audioPlayer, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Map<String, String>> symbols = ref.watch(symbolsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${word.id} ${word.eng}')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: BreadCrumb(items: [
                    BreadCrumbItem(content: Text(word.category)),
                    BreadCrumbItem(content: Text(word.level)),
                    BreadCrumbItem(content: Text(word.pum)),
                    BreadCrumbItem(content: Text(word.id))
                  ], divider: const Icon(Icons.chevron_right)),
                ),
              )),
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(word.eng,
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    symbols.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                        data: (symbols) {
                          return Text(word.ipaPron(symbols));
                        }),
                    IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () async {
                          await audioPlayer.stop();
                          await audioPlayer
                              .setAsset('assets/mp3/${word.mp3Eng}.mp3');
                          await audioPlayer.play();
                          await audioPlayer
                              .setAsset('assets/mp3/${word.mp3Jap}.mp3');
                          await audioPlayer.play();
                        })
                  ]),
            ),
          ),
          const Divider(indent: 10, endIndent: 10, color: Colors.grey),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Badge(
                          badgeContent: Text(word.pum[0],
                              style: const TextStyle(color: Colors.white)),
                          badgeColor: Colors.redAccent,
                          elevation: 0,
                          position: BadgePosition.topStart(),
                          shape: BadgeShape.square,
                          borderRadius: BorderRadius.circular(7)),
                      Expanded(
                        child: Html(data: word.toHtml(word.jap), style: {
                          '*': Style(
                              fontSize: FontSize.large,
                              lineHeight: LineHeight.rem(
                                  word.jap.contains('<rt>') ? 1.5 : 1)),
                          'em': Style(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold)
                        }),
                      ),
                    ],
                  ),
                  word.exp != null
                      ? Html(data: word.toHtml(word.exp!), style: {
                          '*': Style(
                              fontSize: FontSize.large,
                              lineHeight: LineHeight.rem(
                                  word.jap.contains('<rt>') ? 1.5 : 1)),
                          'em': Style(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold)
                        })
                      : Container(),
                  Html(data: word.exEng, style: {
                    '*': Style(fontSize: FontSize.large),
                    'em': Style(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        textDecoration: TextDecoration.underline,
                        textDecorationColor: Colors.black,
                        color: Colors.redAccent)
                  }),
                  Html(data: word.toHtml(word.exJap), style: {
                    '*': Style(fontSize: FontSize.large),
                    'em': Style(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        textDecoration: TextDecoration.underline,
                        textDecorationColor: Colors.black,
                        color: Colors.redAccent)
                  })
                ]),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        word.isState('Remembered', user)
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : word.isState('Forgot', user)
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.help, color: Colors.grey),
                        Text(word.isState('Remembered', user)
                            ? 'Remembered at: ${DateFormat('yyyy/MM/dd HH:mm').format(user.words.firstWhere((w) => word.id == w['id'])['updatedAt'])}'
                            : word.isState('Forgot', user)
                                ? 'Forgot at: ${DateFormat('yyyy/MM/dd HH:mm').format(user.words.firstWhere((w) => word.id == w['id'])['updatedAt'])}'
                                : 'Not remembered')
                      ],
                    )),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
