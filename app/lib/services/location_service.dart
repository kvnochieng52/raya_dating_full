import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  /// Ensures location services are on and the app has at least
  /// while-in-use permission. Throws [LocationException] on failure.
  static Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(
        'Location services are turned off on this device. Enable them and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }
  }

  /// Reads the device's current position. Asks for permission first.
  static Future<LocationPosition> getCurrentLocation() async {
    await ensurePermission();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return LocationPosition(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static Future<void> openSystemSettings() => Geolocator.openAppSettings();

  /// Great-circle distance in kilometres.
  static double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return meters / 1000.0;
  }
}

class LocationPosition {
  LocationPosition({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}
