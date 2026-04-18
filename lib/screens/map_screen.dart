import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double? lat;
  final double? lng;

  const MapScreen({super.key, this.lat, this.lng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final LatLng initialPosition = const LatLng(26.8467, 80.9462);

  final Map<String, Marker> markerMap = {};

  late StreamSubscription<QuerySnapshot> _subscription;

  bool hasMovedCamera = false;

  @override
  void initState() {
    super.initState();
    listenToAlerts();
  }

  /// 🎨 Marker Color Logic
  BitmapDescriptor getMarkerColor(String type) {
    switch (type.toLowerCase()) {
      case "fire":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case "medical":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case "crime":
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case "accident":
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void listenToAlerts() {
    _subscription = FirebaseFirestore.instance
        .collection("alerts")
        .snapshots()
        .listen((snapshot) {
          markerMap.clear();

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final double lat = (data['lat'] as num).toDouble();
            final double lng = (data['lng'] as num).toDouble();
            final String type = data['type'] ?? "unknown";

            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              icon: getMarkerColor(type),

              onTap: () {
                showAlertOptions(doc.id, data);
              },

              infoWindow: InfoWindow(title: type, snippet: data['status']),
            );

            markerMap[doc.id] = marker;
          }

          if (!mounted) return;
          setState(() {});

          /// 🎯 NEW: Focus on passed location (SAFE ADD)
          if (widget.lat != null &&
              widget.lng != null &&
              mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(widget.lat!, widget.lng!), 15),
            );
          }
          /// Existing logic (latest alert zoom)
          else if (!hasMovedCamera &&
              snapshot.docs.isNotEmpty &&
              mapController != null) {
            hasMovedCamera = true;

            final latest = snapshot.docs.last.data() as Map<String, dynamic>;

            mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                  (latest['lat'] as num).toDouble(),
                  (latest['lng'] as num).toDouble(),
                ),
                14,
              ),
            );
          }
        });
  }

  /// 🧭 OPEN GOOGLE MAP NAVIGATION
  void openNavigation(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// 🙋 ALERT ACTION POPUP
  void showAlertOptions(String docId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              Text(
                "🚨 ${data['type'].toUpperCase()} ALERT",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              /// ✅ Accept Alert
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("alerts")
                      .doc(docId)
                      .update({"status": "accepted"});

                  Navigator.pop(context);
                },
                child: const Text("Accept Alert"),
              ),

              const SizedBox(height: 10),

              /// 🧭 Navigate
              ElevatedButton(
                onPressed: () {
                  openNavigation(
                    (data['lat'] as num).toDouble(),
                    (data['lng'] as num).toDouble(),
                  );
                },
                child: const Text("Navigate"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🚨 Live Map"),
        backgroundColor: Colors.black,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 12,
        ),
        markers: markerMap.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
