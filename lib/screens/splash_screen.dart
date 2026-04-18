import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'citizen_dashboard.dart';
import 'volunteer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    /// ❌ अगर login नहीं है
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    /// 🔥 USER DOC HANDLE (MOST IMPORTANT)
    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final doc = await userRef.get();

    /// 👉 अगर user doc नहीं है → create करो
    if (!doc.exists) {
      await userRef.set({
        "email": user.email,
        "role": "citizen", // default
        "createdAt": DateTime.now(),
      });
    }

    /// 🔄 role fetch करो
    final updatedDoc = await userRef.get();
    final role = updatedDoc.data()?['role'] ?? "citizen";

    /// 🚀 AUTO REDIRECT
    if (role == "citizen") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CitizenDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "KAVACH",
          style: TextStyle(
            color: Colors.red,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}