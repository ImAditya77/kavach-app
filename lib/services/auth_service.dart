import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 SIGN UP + SAVE USER DATA
  static Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;

    if (user != null) {
      await saveUserData(uid: user.uid, email: email);
    }

    return user;
  }

  /// 💾 SAVE USER DATA (NEW 🔥)
  static Future<void> saveUserData({
    required String uid,
    required String email,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "email": email,
      "name": "",
      "phone": "",
      "emergencyPhone": "", // 🚨 NEW FEATURE
      "bloodGroup": "",
      "address": "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// 🔑 LOGIN
  static Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// 🚪 LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// 👤 CURRENT USER
  static User? get currentUser => _auth.currentUser;
}
