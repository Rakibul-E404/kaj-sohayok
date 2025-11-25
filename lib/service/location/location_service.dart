import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton pattern: private constructor & single instance
  LocationService._privateConstructor();
  static final LocationService _instance = LocationService._privateConstructor();
  factory LocationService() => _instance;

  /// Checks if location services are enabled and requests permission if needed.
  /// Throws exceptions if services are disabled or permissions denied.
  Future<bool> _handlePermission() async {
    // Check if location services are enabled on device

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If not enabled, throw exception
      throw LocationServiceDisabledException('Location services are disabled.');
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, request permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission still denied after request, throw exception
        throw PermissionDeniedException('Location permissions are denied');
      }
    }

    // If permission is denied forever, app can't request permission anymore
    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
          'Location permissions are permanently denied.');
    }

    // Permissions granted
    return true;
  }

  /// Get the current device position with specified accuracy (default high).
  /// Throws exceptions if permissions/services not available.
  Future<Position> getCurrentPosition({LocationAccuracy accuracy = LocationAccuracy.high}) async {
    await _handlePermission();
    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  /// Provides a stream of position updates.
  /// accuracy: desired accuracy (default best),
  /// distanceFilterMeters: minimum meters before emitting new event.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilterMeters = 10,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}

/// Exception for location services disabled
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

/// Exception for permission denied or denied forever
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
