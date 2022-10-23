import 'package:audio_session/audio_session.dart';
import 'package:eiken_grade_1/components/words_list_view.dart';
import 'package:eiken_grade_1/components/configuration_drawer.dart';
import 'package:eiken_grade_1/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final isGoogleSignedIn = ref.watch(authProvider).isGoogleSignedIn;
    final currentFirebaseUser = ref.watch(authProvider).currentFirebaseUser;
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Eiken Grade 1'),
          actions: [
            IconButton(
              icon: isGoogleSignedIn
                  ? currentFirebaseUser!.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                          currentFirebaseUser.photoURL!,
                        ))
                      : const Icon(Icons.account_circle)
                  : const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState!.openEndDrawer();
              },
            ),
          ],
        ),
        body: isGoogleSignedIn
            ? WordsListView(audioPlayer)
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.only(right: 24),
                        backgroundColor: Colors.white,
                      ),
                      icon: SvgPicture.asset(
                          'assets/btn_google_light_normal.svg'),
                      label: Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.black.withOpacity(0.54)),
                      ),
                      onPressed: () async {
                        try {
                          await ref.read(authProvider).signInWithGoogle();
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                    ),
                  ])),
        endDrawer: SettingPage(audioPlayer));
  }
}
