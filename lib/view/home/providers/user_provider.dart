import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  String _languagePreference = 'fr'; // Valeur par défaut

  UserProvider({required FirebaseFirestore firestore}) : _firestore = firestore;

  String get languagePreference => _languagePreference;

  Future<void> fetchUserLanguage(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _languagePreference = doc['languagePreference'] ?? 'fr';
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user language: $e');
    }
  }

  Future<void> updateLanguagePreference(
      String userId, String newLanguage) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'languagePreference': newLanguage});
      _languagePreference = newLanguage;
      notifyListeners();
    } catch (e) {
      print('Error updating language preference: $e');
    }
  }
}
