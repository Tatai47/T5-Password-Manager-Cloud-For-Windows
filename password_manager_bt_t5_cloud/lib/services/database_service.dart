import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/password_entry.dart';

class DatabaseService {
  // Get the current user's ID
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Reference to THIS user's private collection
  CollectionReference get _myRepo {
    if (_uid == null) throw Exception("Not logged in");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('passwords');
  }

  // Save (Works Offline & Online)
  Future<void> saveEntry(PasswordEntry entry) async {
    await _myRepo.doc(entry.id).set(entry.toMap());
  }

  // Delete
  Future<void> deleteEntry(String id) async {
    await _myRepo.doc(id).delete();
  }

  // Get Real-time Stream
  Stream<List<PasswordEntry>> getPasswordsStream() {
    return _myRepo.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PasswordEntry.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
