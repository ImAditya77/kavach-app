import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyTypeScreen extends StatefulWidget {
  const EmergencyTypeScreen({super.key});

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  bool sending = false; // 🔥 double tap block (UI level)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select Emergency"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            emergencyCard("fire", Icons.local_fire_department),
            emergencyCard("accident", Icons.car_crash),
            emergencyCard("medical", Icons.medical_services),
            emergencyCard("crime", Icons.local_police),
            emergencyCard("electric", Icons.electrical_services),
            emergencyCard("disaster", Icons.warning),
          ],
        ),
      ),
    );
  }

  Widget emergencyCard(String type, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (sending) return; // 🔥 prevent rapid multi taps
        sending = true;

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Login required ❌")));
            sending = false;
            return;
          }

          /// 📍 location
          final position = await LocationService.getCurrentLocation();

          if (position.latitude == 0 || position.longitude == 0) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Invalid location ❌")));
            sending = false;
            return;
          }

          final now = DateTime.now();
          final cooldownRef = FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("meta")
              .doc("cooldown");

          final alertsRef = FirebaseFirestore.instance.collection("alerts");

          /// 🔥 TRANSACTION (core fix)
          await FirebaseFirestore.instance.runTransaction((tx) async {
            final cooldownSnap = await tx.get(cooldownRef);

            DateTime? lastTime;

            if (cooldownSnap.exists) {
              final data = cooldownSnap.data();
              final ts = data?['lastAlert'];

              if (ts is Timestamp) {
                lastTime = ts.toDate();
              }
            }

            /// ⏳ cooldown 60 sec
            if (lastTime != null && now.difference(lastTime).inSeconds < 60) {
              throw Exception("cooldown");
            }

            /// 🔥 create alert doc
            final newDoc = alertsRef.doc();

            tx.set(newDoc, {
              "type": type,
              "lat": position.latitude,
              "lng": position.longitude,
              "status": "pending",
              "userId": user.uid,
              "email": user.email,
              "timestamp": now,
            });

            /// 🔥 update cooldown
            tx.set(cooldownRef, {"lastAlert": now});
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${type.toUpperCase()} alert sent 🚨"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MapScreen()),
          );
        } catch (e) {
          if (!mounted) return;

          if (e.toString().contains("cooldown")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Wait 60 sec before next alert ⏳")),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        } finally {
          sending = false;
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              type.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
