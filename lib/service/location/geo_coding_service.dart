import 'package:geocoding/geocoding.dart';

import 'geo-address.dart';


class GeocodingService {
  // Singleton pattern
  GeocodingService._privateConstructor();
  static final GeocodingService _instance = GeocodingService._privateConstructor();
  factory GeocodingService() => _instance;

  /// Reverse geocode coordinates to an Address object
  Future<Address?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return null;
      }

      Placemark place = placemarks.first;

      return Address(
        street: place.street,
        subLocality: place.subLocality,
        locality: place.locality,
        postalCode: place.postalCode,
        country: place.country,
      );
    } catch (e) {
      // Handle or log error as needed
      throw Exception('Failed to reverse geocode coordinates: $e');
    }
  }
}
