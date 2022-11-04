import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eiken_grade_1/model/configuration.dart';
import 'package:flutter/material.dart';

class Firestore {
  static final FirebaseFirestore _firestoreInstance =
      FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');

  static Future<void> addUser(dynamic user, Configuration configuration) async {
    try {
      await userRef.doc(user['id']).set({
        'username': user['username'],
        'level': configuration.level,
        'state': configuration.state,
        'listen_eng': configuration.listenEng,
        'listen_jap': configuration.listenJap,
        'play_speed': configuration.playSpeed
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String id) async {
    try {
      final snapshot = await userRef.doc(id).get();
      final user = snapshot.data()!;
      return {
        'id': id,
        'username': user['username'],
        'level': user['level'],
        'state': user['state'],
        'listenEng': user['listen_eng'],
        'listenJap': user['listen_jap'],
        'playSpeed': user['play_speed'],
      };
    } catch (e) {
      debugPrint(e.toString());
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
                'updatedAt': word['updated_at'].toDate()
              })
          .toList();
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint(e.toString());
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
        'updated_at': Timestamp.fromDate(word['updatedAt'])
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<void> updateConfiguration(
      String userId, Configuration configuration) async {
    try {
      await userRef.doc(userId).update({
        'level': configuration.level,
        'state': configuration.state,
        'listen_eng': configuration.listenEng,
        'listen_jap': configuration.listenJap,
        'play_speed': configuration.playSpeed
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
