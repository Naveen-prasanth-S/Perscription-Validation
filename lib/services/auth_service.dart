import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    // Optional: Set language to avoid null locale warnings
    try {
      _auth.setLanguageCode('en');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Sign up method
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Get the UID of the newly created user
      String uid = userCredential.user!.uid;

      // 3️⃣ Save additional user info in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Login method
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Optional: Get current user
  User? get currentUser => _auth.currentUser;
}
