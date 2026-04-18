import 'package:flutter/material.dart';
import 'emergency_type_screen.dart';
import 'map_screen.dart'; // 🗺️ NEW IMPORT

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Kavach"),
        backgroundColor: Colors.black,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Emergency SOS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: GestureDetector(
              // 🔥 UX Improvement
              onLongPressStart: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Hold detected... sending alert"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },

              // 🚨 Navigate to emergency selection
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyTypeScreen(),
                  ),
                );
              },

              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.6),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),

                child: const Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "Hold to send emergency alert",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          // 🗺️ NEW BUTTON FOR MAP
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            child: const Text("View Map", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
