import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';

import 'map_screen.dart';
import 'alert_list_screen.dart';
import 'emergency_type_screen.dart';
import 'report_issue_screen.dart';
import 'profile_screen.dart';
import 'volunteer_dashboard.dart';

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  static DateTime? lastAlertTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Citizen Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🔥 ANIMATED SOS BUTTON
              const PulsingSOS(),

              const SizedBox(height: 20),

              /// 📍 MAP
              buildMap(context),

              const SizedBox(height: 20),

              /// 🚑 QUICK ALERTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  quickBtn(context, Icons.local_police, "Police"),
                  quickBtn(context, Icons.local_hospital, "Medical"),
                  quickBtn(context, Icons.local_fire_department, "Fire"),
                ],
              ),

              const SizedBox(height: 20),

              tile(context, "My Alerts", Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertListScreen()),
                );
              }),

              const SizedBox(height: 10),

              tile(context, "Report Issue", Icons.warning, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔴 MAP UI
  Widget buildMap(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("Open Map", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// 🔘 TILE
  Widget tile(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red),
                const SizedBox(width: 10),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// 🔘 QUICK ALERT
  Widget quickBtn(BuildContext context, IconData icon, String type) {
    return GestureDetector(
      onTap: () async {
        try {
          /// 🔥 LOADING
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );

          final now = DateTime.now();

          if (lastAlertTime != null &&
              now.difference(lastAlertTime!).inSeconds < 60) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Wait before sending again ⏳")),
            );
            return;
          }

          final position = await LocationService.getCurrentLocation();

          if (position.latitude == 0 || position.longitude == 0) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Invalid location ❌")));
            return;
          }

          final user = FirebaseAuth.instance.currentUser;

          await FirebaseFirestore.instance.collection("alerts").add({
            "type": type.toLowerCase(),
            "lat": position.latitude,
            "lng": position.longitude,
            "status": "pending",
            "userId": user?.uid,
            "timestamp": DateTime.now(),
          });

          lastAlertTime = now;

          Navigator.pop(context);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$type Alert Sent 🚨")));
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      },
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(height: 5),
              Text(type, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 PULSING SOS
class PulsingSOS extends StatefulWidget {
  const PulsingSOS({super.key});

  @override
  State<PulsingSOS> createState() => _PulsingSOSState();
}

class _PulsingSOSState extends State<PulsingSOS>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: controller,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyTypeScreen()),
          );
        },
        child: Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(color: Colors.redAccent, blurRadius: 30),
            ],
          ),
          child: const Center(
            child: Text(
              "SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
