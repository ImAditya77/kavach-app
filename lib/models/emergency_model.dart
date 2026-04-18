class EmergencyModel {
  final String type;
  final double latitude;
  final double longitude;
  final String role;
  final DateTime timestamp;
  final String status;

  EmergencyModel({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.role,
    required this.timestamp,
    required this.status,
  });
}
