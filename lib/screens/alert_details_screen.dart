import 'package:flutter/material.dart';

class AlertDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AlertDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Alert Details"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['type'].toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Status: ${data['status']}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              "Latitude: ${data['lat']}",
              style: const TextStyle(color: Colors.grey),
            ),

            Text(
              "Longitude: ${data['lng']}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            const Text(
              "Emergency reported by citizen",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}