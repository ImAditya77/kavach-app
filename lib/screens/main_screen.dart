import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final LatLng initialPosition = const LatLng(26.8467, 80.9462); // Lucknow

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    listenToAlerts();
  }

  void listenToAlerts() {
    FirebaseFirestore.instance
        .collection("alerts")
        .snapshots()
        .listen((snapshot) {
      final Set<Marker> newMarkers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final double lat = (data['lat'] as num).toDouble();
        final double lng = (data['lng'] as num).toDouble();

        newMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),

            // 🔥 Different colors based on type
            icon: getMarkerColor(data['type']),

            infoWindow: InfoWindow(
              title: data['type'].toUpperCase(),
              snippet: "Status: ${data['status']}",
            ),
          ),
        );
      }

      setState(() {
        markers = newMarkers;
      });
    });
  }

  // 🎯 Marker color logic
  BitmapDescriptor getMarkerColor(String type) {
    switch (type) {
      case "fire":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case "medical":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case "crime":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case "accident":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  // 📍 Move camera to latest alert
  void moveToLatest(Set<Marker> markers) {
    if (markers.isNotEmpty && mapController != null) {
      final latest = markers.last.position;

      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(latest, 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("🚨 Live Emergency Map"),
        backgroundColor: Colors.black,
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          // 🔥 Floating button to focus latest alert
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.my_location),
              onPressed: () => moveToLatest(markers),
            ),
          ),
        ],
      ),
    );
  }
}