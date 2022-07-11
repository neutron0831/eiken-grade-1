import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static final FirebaseFirestore _firestoreInstance =
      FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');

  static Future<Map<String, String>> getUser(String username) async {
    try {
      final snapshot =
          await userRef.where('username', isEqualTo: username).get();
      final user = snapshot.docs[0].data();
      return {
        'id': snapshot.docs[0].id,
        'username': user['username'],
      };
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getWords(String userId) async {
    try {
      final wordRef = userRef.doc(userId).collection('word');
      final snapshot = await wordRef.get();
      return snapshot.docs
          .map((word) => {
                'id': word['id'].toString(),
                'remembered': word['remembered'],
                'updatedAt': word['updated_at']
              })
          .toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> addWord(String userId, Map<String, dynamic> word) async {
    try {
      final wordRef = userRef.doc(userId).collection('word');
      await wordRef.add({
        'id': word['id'],
        'remembered': word['remembered'],
        'updated_at': Timestamp.now()
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> updateWord(
      String userId, Map<String, dynamic> word) async {
    try {
      final wordRef = userRef.doc(userId).collection('word');
      final snapshot = await wordRef.where('id', isEqualTo: word['id']).get();
      final wordId = snapshot.docs[0].id;
      await wordRef.doc(wordId).update({
        'id': word['id'],
        'remembered': word['remembered'],
        'updated_at': Timestamp.now()
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
