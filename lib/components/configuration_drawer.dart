import 'package:eiken_grade_1/components/progress_charts.dart';
import 'package:eiken_grade_1/model/configuration.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/providers/words_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class SettingPage extends ConsumerWidget {
  final AudioPlayer audioPlayer;

  const SettingPage(this.audioPlayer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final words = ref.read(wordsProvider);
    final config = ref.watch(configurationProvider).configuration;
    return SafeArea(
      child: Drawer(
          child: Scaffold(
        appBar: AppBar(title: const Text('Menu')),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: words.when(
              loading: () => const Text('uuu'),
              error: (err, stack) => Text('Error: $err'),
              data: (words) {
                return Column(children: [
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
                          value: config.level,
                          items: config.levels!
                              .map((level) => DropdownMenuItem(
                                  value: level, child: Text(level)))
                              .toList(),
                          onChanged: (String? value) {
                            ref
                                .read(configurationProvider.notifier)
                                .setLevel(value!);
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
                          value: config.state,
                          items: config.states!
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (String? value) {
                            ref
                                .read(configurationProvider.notifier)
                                .setState(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.build_circle),
                    title: Row(
                      children: [
                        const SizedBox(
                            width: 120, child: Text('Listen on Tap:')),
                        SizedBox(
                            width: 26,
                            child: Text(config.listenEng ? 'ON' : 'OFF')),
                        Switch(
                          value: config.listenEng,
                          onChanged: (bool? value) {
                            ref
                                .read(configurationProvider.notifier)
                                .toggleListenEng(value!);
                            if (!config.listenEng) {
                              ref
                                  .read(configurationProvider.notifier)
                                  .toggleListenJap(value);
                            }
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
                            width: 26,
                            child: Text(config.listenJap ? 'ON ' : 'OFF')),
                        Switch(
                          value: config.listenJap,
                          onChanged: config.listenEng
                              ? (bool? value) {
                                  ref
                                      .read(configurationProvider.notifier)
                                      .toggleListenJap(value!);
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
                        Text('Play Speed: x${config.playSpeed}'),
                        SliderTheme(
                          data: const SliderThemeData(
                              activeTickMarkColor: Colors.green,
                              inactiveTickMarkColor: Colors.transparent),
                          child: Slider(
                              value: config.playSpeed,
                              min: 0.5,
                              max: 4.0,
                              divisions: 7,
                              onChanged: (double? value) async {
                                await audioPlayer.setSpeed(value!);
                                ref
                                    .read(configurationProvider.notifier)
                                    .setPlaySpeed(value);
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
                    for (String level in config.levels!)
                      ListTile(
                        leading: const Icon(Icons.check_circle),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${level != 'Idioms' ? 'Level ' : ''}$level: ${user.wordsNum(words, level, 'Remembered')}/${words.where((word) => word.level == level).length}',
                            ),
                            LinearProgressIndicator(
                              value: user.wordsNum(words, level, 'Remembered') /
                                  user.wordsNum(words, level, 'All'),
                            ),
                          ],
                        ),
                      ),
                  ]),
                  Container(
                    padding: const EdgeInsets.only(top: 14, left: 14),
                    height: 200,
                    child: ProgressChart(user.words, animate: false),
                  ),
                ]);
              }),
        ),
      )),
    );
  }
}
