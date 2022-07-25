import 'package:audio_session/audio_session.dart';
import 'package:eiken_grade_1/components/words_list_view.dart';
import 'package:eiken_grade_1/components/configuration_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class TopPage extends ConsumerStatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  TopPageState createState() => TopPageState();
}

class TopPageState extends ConsumerState<TopPage> {
  AudioPlayer audioPlayer = AudioPlayer();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _setupSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  void initState() {
    super.initState();
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
        body: WordsListView(audioPlayer),
        endDrawer: SettingPage(audioPlayer));
  }
}
