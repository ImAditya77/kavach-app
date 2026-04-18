import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';

class AlertListScreen extends StatelessWidget {
  const AlertListScreen({super.key});

  Color getColor(String type) {
    switch (type.toLowerCase()) {
      case "fire":
        return Colors.red;
      case "medical":
        return Colors.green;
      case "police":
      case "crime":
        return Colors.blue;
      case "accident":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double toDoubleSafe(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🚨 Live Alerts"),
        backgroundColor: Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("alerts")
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          /// ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          /// 📭 EMPTY STATE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No alerts yet 🚫",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              final type = (data['type'] ?? "unknown").toString();
              final status = (data['status'] ?? "pending").toString();

              final lat = toDoubleSafe(data['lat']);
              final lng = toDoubleSafe(data['lng']);

              final color = getColor(type);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    /// 🎨 ICON
                    leading: Icon(Icons.warning, color: color, size: 28),

                    /// 🧾 TITLE
                    title: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// 📍 DETAILS
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "📍 $lat , $lng",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            color: status == "accepted"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    /// 🔥 ACTIONS
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// ACCEPT BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          onPressed: status == "accepted"
                              ? null
                              : () async {
                                  await FirebaseFirestore.instance
                                      .collection("alerts")
                                      .doc(docId)
                                      .update({"status": "accepted"});

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Alert Accepted 🚀"),
                                    ),
                                  );
                                },
                          child: Text(
                            status == "accepted" ? "Done" : "Accept",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        const SizedBox(height: 5),

                        /// 📍 VIEW MAP
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(lat: lat, lng: lng),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
