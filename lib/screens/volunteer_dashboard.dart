import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';

import 'citizen_dashboard.dart'; // 🔥 NEW
import 'profile_screen.dart'; // 🔥 NEW

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int lastAlertCount = 0;

  /// 📞 CALL
  void callNumber(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// 🧭 NAVIGATION
  void openNavigation(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("🚑 Volunteer Panel"),
        actions: [
          /// 🔄 SWITCH TO CITIZEN
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CitizenDashboard()),
              );
            },
          ),

          /// 👤 PROFILE
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("alerts")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;

          /// 🔔 NOTIFICATION
          if (alerts.length > lastAlertCount && alerts.isNotEmpty) {
            final latest = alerts.first.data() as Map<String, dynamic>;

            NotificationService.showNotification(
              "🚨 New Alert",
              "${latest['type']} reported",
            );

            lastAlertCount = alerts.length;
          }

          if (alerts.isEmpty) {
            return const Center(
              child: Text(
                "No alerts yet 🚫",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index].data() as Map<String, dynamic>;
              final docId = alerts[index].id;

              final lat = (alert['lat'] as num).toDouble();
              final lng = (alert['lng'] as num).toDouble();

              final userId = alert['userId'];

              return FutureBuilder<DocumentSnapshot>(
                future: userId != null
                    ? FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .get()
                    : null,
                builder: (context, userSnap) {
                  final userData =
                      userSnap.data?.data() as Map<String, dynamic>?;

                  final name = userData?['name'] ?? "Unknown";
                  final phone = userData?['phone'] ?? "";
                  final emergency = userData?['emergencyPhone'] ?? "";
                  final blood = userData?['bloodGroup'] ?? "";

                  final status = alert['status'] ?? "pending";

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        "${alert['type'].toUpperCase()} 🚨",
                        style: const TextStyle(color: Colors.white),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "👤 $name",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "📞 $phone",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "☎️ Emergency: $emergency",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "🩸 Blood: $blood",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "📍 $lat , $lng",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Status: $status",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),

                      /// 🔥 ACTIONS
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: status == "accepted"
                                ? null
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection("alerts")
                                        .doc(docId)
                                        .update({"status": "accepted"});

                                    openNavigation(lat, lng);
                                  },
                            child: Text(
                              status == "accepted" ? "Done" : "Accept",
                            ),
                          ),

                          const SizedBox(height: 5),

                          if (phone.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () => callNumber(phone),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
