import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'citizen_dashboard.dart';
import 'volunteer_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emergencyController = TextEditingController();
  final bloodController = TextEditingController();
  final addressController = TextEditingController();

  bool loading = true;
  String role = "citizen";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// 🔄 LOAD DATA
  void loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? "";
      phoneController.text = data['phone'] ?? "";
      emergencyController.text = data['emergencyPhone'] ?? "";
      bloodController.text = data['bloodGroup'] ?? "";
      addressController.text = data['address'] ?? "";
      role = data['role'] ?? "citizen";
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  /// 💾 SAVE PROFILE
  void saveData() async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": nameController.text,
      "phone": phoneController.text,
      "emergencyPhone": emergencyController.text,
      "bloodGroup": bloodController.text,
      "address": addressController.text,
      "role": role,
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated ✅")));
  }

  /// 🔄 SWITCH ROLE (FULL FIX)
  void switchRole() async {
    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final doc = await userRef.get();

    final currentRole = doc.data()?['role'] ?? "citizen";

    final newRole = currentRole == "citizen" ? "volunteer" : "citizen";

    /// 🔥 UPDATE FIRESTORE SAFELY
    await userRef.set({"role": newRole}, SetOptions(merge: true));

    if (!mounted) return;

    /// 🔄 UPDATE LOCAL STATE (IMPORTANT)
    setState(() {
      role = newRole;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Switched to $newRole 🔄")));

    /// 🚀 FORCE NAVIGATION RESET
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => newRole == "citizen"
            ? const CitizenDashboard()
            : const VolunteerDashboard(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// 👤 ROLE BOX
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Role: ${role.toUpperCase()}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: switchRole,
                            child: const Text(
                              "Switch",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    buildField("Name", nameController),
                    buildField("Phone", phoneController),
                    buildField("Emergency Contact", emergencyController),
                    buildField("Blood Group", bloodController),
                    buildField("Address", addressController),

                    const SizedBox(height: 20),

                    /// 💾 SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// 🔘 FIELD BUILDER
  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
