import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 📍 Get Current Location (SAFE + COMPLETE)
  static Future<Position> getCurrentLocation() async {
    try {
      // 🔍 Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled. Please enable GPS.");
      }

      // 🔐 Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // 🟡 Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }

      // 🔴 If permanently denied
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Location permission permanently denied. Enable it from settings.",
        );
      }

      // 📍 Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  /// 📍 Open App Settings (if permission denied forever)
  static Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  /// 📍 Open Location Settings (GPS off case)
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
