import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'geo-address.dart';
import 'geo_coding_service.dart';
import 'location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  // Observable position, null if not fetched yet
  final Rxn<Position> currentPosition = Rxn<Position>();
  final Rxn<Address> currentAddress = Rxn<Address>();

  // Observable error message, if any error occurs
  final RxnString errorMessage = RxnString();

  /// Fetch current location once and update observables
  Future<void> fetchCurrentLocation() async {
    try {
      errorMessage.value = null; // clear previous error
      final Position pos = await _locationService.getCurrentPosition();
      currentPosition.value = pos;
      // Fetch address after getting position
      final Address? address = await _geocodingService
          .getAddressFromCoordinates(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
      currentAddress.value = address;
    } catch (e) {
      currentPosition.value = null;
      errorMessage.value = e.toString();
    }
  }

  /// Listen continuously to location updates.
  /// Updates currentPosition automatically.
  Stream<Position> getLocationStream() {
    return _locationService.getPositionStream();
  }

  /// Optionally call this to start listening and update position reactively
  void startListening() {
    _locationService.getPositionStream().listen(
      (Position pos) {
        currentPosition.value = pos;
      },
      onError: (dynamic e) {
        errorMessage.value = e.toString();
      },
    );
  }
}
