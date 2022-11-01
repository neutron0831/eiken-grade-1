import 'package:eiken_grade_1/firebase_options.dart';
import 'package:eiken_grade_1/pages/top_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eiken_grade_1/utils/configure_nonweb.dart'
    if (dart.library.html) 'package:eiken_grade_1/utils/configure_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrl();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eiken Grade 1',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TopPage(),
    );
  }
}
