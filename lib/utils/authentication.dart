import 'package:eiken_grade_1/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier extends ChangeNotifier {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? currentFirebaseUser;
  bool isGoogleSignedIn = false;

  Future<void> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      final dynamic googleUser = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(googleProvider)
          : await GoogleSignIn(
                  scopes: ['email'],
                  clientId: DefaultFirebaseOptions.currentPlatform.iosClientId)
              .signIn();
      if (googleUser != null) {
        final dynamic googleAuth =
            kIsWeb ? googleUser.credential : await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: kIsWeb ? '' : googleAuth.idToken);
        final UserCredential result =
            await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = result.user;
        isGoogleSignedIn = true;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> signOutFromGoogle() async {
    if (isGoogleSignedIn) {
      try {
        await GoogleSignIn(
                clientId: DefaultFirebaseOptions.currentPlatform.iosClientId)
            .signOut();
        isGoogleSignedIn = false;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  AuthNotifier() {
    try {
      signInWithGoogle();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

final authProvider =
    ChangeNotifierProvider<AuthNotifier>((ref) => AuthNotifier());
