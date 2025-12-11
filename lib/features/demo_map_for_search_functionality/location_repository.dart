// // // import 'dart:convert';

// // // import 'package:flutter/material.dart';
// // // import 'package:geocoding/geocoding.dart' as geocoding;
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:location/location.dart';
// // // import 'package:permission_handler/permission_handler.dart';

// // // class LocationRepository {
// // //   static final LocationRepository _instance = LocationRepository._internal();

// // //   factory LocationRepository() {
// // //     return _instance;
// // //   }

// // //   LocationRepository._internal();

// // //   // State variables
// // //   bool _isLoading = false;
// // //   List<dynamic> _placePredictions = [];
// // //   LatLng? _startingLocationCoordinates;
// // //   LatLng? _endingLocationCoordinates;
// // //   LatLng? _currentLocationCoordinates;
// // //   final Set<Marker> _markers = <Marker>{};
// // //   Polyline? _polyline;

// // //   // Getters for state
// // //   bool get isLoading => _isLoading;

// // //   List<dynamic> get placePredictions => _placePredictions;

// // //   LatLng? get startingLocationCoordinates => _startingLocationCoordinates;

// // //   LatLng? get endingLocationCoordinates => _endingLocationCoordinates;

// // //   LatLng? get currentLocationCoordinates => _currentLocationCoordinates;

// // //   Set<Marker> get markers => _markers;

// // //   Polyline? get polyline => _polyline;

// // //   // Setter for current location coordinates
// // //   set currentLocationCoordinates(LatLng? coordinates) {
// // //     _currentLocationCoordinates = coordinates;
// // //     if (coordinates != null) {
// // //       //addCurrentLocationMarker();
// // //     }
// // //   }

// // //   set startingLocationCoordinates(LatLng? coordinates) {
// // //     _startingLocationCoordinates = coordinates;
// // //     if (coordinates != null) {
// // //       _updateMarker('starting-location', coordinates, 'Pickup Location');
// // //     }
// // //   }

// // //   // Method to set current location coordinates
// // //   void setCurrentLocationCoordinates(LatLng coordinates) {
// // //     _currentLocationCoordinates = coordinates;
// // //     // addCurrentLocationMarker();
// // //   }

// // //   void clearPolylines() {
// // //     _polyline = null;
// // //   }

// // //   void clearLocationCoordinates() {
// // //     startingLocationCoordinates = null;
// // //     _endingLocationCoordinates = null;
// // //   }

// // //   // Add a method to set starting location coordinates
// // //   void setStartingLocationCoordinates(LatLng coordinates) {
// // //     _startingLocationCoordinates = coordinates;
// // //     _updateMarker('starting-location', coordinates, 'Pickup Location');
// // //   }

// // //   // Add a method to set ending location coordinates
// // //   void setEndingLocationCoordinates(LatLng coordinates) {
// // //     _endingLocationCoordinates = coordinates;
// // //     _updateMarker('ending-location', coordinates, 'Destination');
// // //   }

// // //   void clearPlacePredictions() {
// // //     _placePredictions = [];
// // //   }

// // //   // Fetch current location
// // //   Future<LatLng?> getCurrentLocation() async {
// // //     Location location = Location();

// // //     try {
// // //       // Check if location service is enabled
// // //       bool serviceEnabled = await location.serviceEnabled();
// // //       if (!serviceEnabled) {
// // //         serviceEnabled = await location.requestService();
// // //         if (!serviceEnabled) {
// // //           debugPrint("Location services are disabled");
// // //           return null;
// // //         }
// // //       }

// // //       // Check and request location permission
// // //       // PermissionStatus permissionGranted = await location.hasPermission();
// // //       PermissionStatus permissionGranted = await location.hasPermission;
// // //       if (permissionGranted == PermissionStatus.denied) {
// // //         permissionGranted = await location.requestPermission();
// // //         if (permissionGranted != PermissionStatus.granted) {
// // //           debugPrint("Location permission not granted");
// // //           return null;
// // //         }
// // //       }

// // //       // Get the current location data
// // //       LocationData locationData = await location.getLocation();

// // //       // Only proceed if we have valid coordinates
// // //       if (locationData.latitude != null && locationData.longitude != null) {
// // //         _currentLocationCoordinates =
// // //             LatLng(locationData.latitude!, locationData.longitude!);
// // //         // addCurrentLocationMarker();
// // //         return _currentLocationCoordinates;
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Error getting location: $e");
// // //     }

// // //     return null;
// // //   }

// // //   Future<String> getAddressFromLatLng(double latitude, double longitude) async {
// // //     try {
// // //       List<geocoding.Placemark> placemarks =
// // //           await geocoding.placemarkFromCoordinates(latitude, longitude);
// // //       if (placemarks.isNotEmpty) {
// // //         geocoding.Placemark place = placemarks[0];
// // //         return "${place.street}, ${place.locality}, ${place.administrativeArea}";
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Error getting address: $e");
// // //     }
// // //     return "Your Current Location";
// // //   }

// // //   // Place auto-complete suggestions with debouncing
// // //   Future<List<dynamic>> placeAutoComplete(String query) async {
// // //     if (query.isEmpty) {
// // //       _placePredictions = [];
// // //       return _placePredictions;
// // //     }

// // //     _isLoading = true;

// // //     try {
// // //       final Uri uri = Uri.https(
// // //         'maps.googleapis.com',
// // //         'maps/api/place/autocomplete/json',
// // //         {
// // //           'input': query,
// // //           'key': apikey,
// // //         },
// // //       );

// // //       final response = await http.get(uri);

// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);
// // //         if (data['status'] == 'OK') {
// // //           _placePredictions = data['predictions'];
// // //         } else {
// // //           debugPrint('API Error: ${data['status']}');
// // //           _placePredictions = [];
// // //         }
// // //       } else {
// // //         debugPrint('HTTP Error: ${response.statusCode}');
// // //         _placePredictions = [];
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error in place autocomplete: $e');
// // //       _placePredictions = [];
// // //     } finally {
// // //       _isLoading = false;
// // //     }

// // //     return _placePredictions;
// // //   }

// // //   // Fetch place details based on placeId
// // //   Future<LatLng?> fetchPlaceDetails(String placeId, String locationType) async {
// // //     if (placeId.isEmpty) {
// // //       debugPrint('Empty placeId provided');
// // //       return null;
// // //     }

// // //     try {
// // //       final Uri uri = Uri.https(
// // //         'maps.googleapis.com',
// // //         'maps/api/place/details/json',
// // //         {
// // //           'place_id': placeId,
// // //           'fields': 'geometry',
// // //           'key': apikey,
// // //         },
// // //       );

// // //       final response = await http.get(uri);

// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);

// // //         if (data['status'] == 'OK' && data['result'] != null) {
// // //           final location = data['result']['geometry']['location'];
// // //           LatLng locationCoordinates = LatLng(location['lat'], location['lng']);

// // //           if (locationType == 'starting') {
// // //             _startingLocationCoordinates = locationCoordinates;
// // //             _updateMarker('starting-location', _startingLocationCoordinates!,
// // //                 'Pickup Location');
// // //           } else {
// // //             _endingLocationCoordinates = locationCoordinates;
// // //             _updateMarker(
// // //                 'ending-location', _endingLocationCoordinates!, 'Destination');
// // //           }

// // //           // If both locations are set, fetch directions
// // //           if (_startingLocationCoordinates != null &&
// // //               _endingLocationCoordinates != null) {
// // //             await fetchDirections();
// // //           }

// // //           return locationCoordinates;
// // //         } else {
// // //           debugPrint('API Error: ${data['status']}');
// // //         }
// // //       } else {
// // //         debugPrint('HTTP Error: ${response.statusCode}');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error fetching place details: $e');
// // //     }

// // //     return null;
// // //   }

// // //   // Helper to update a marker
// // //   void _updateMarker(String markerId, LatLng position, String title) {
// // //     _markers.removeWhere((marker) => marker.markerId.value == markerId);

// // //     // Set different colors for different marker types
// // //     BitmapDescriptor icon;
// // //     if (markerId == 'starting-location') {
// // //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
// // //     } else if (markerId == 'ending-location') {
// // //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
// // //     } else {
// // //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
// // //     }

// // //     _markers.add(
// // //       Marker(
// // //         markerId: MarkerId(markerId),
// // //         position: position,
// // //         infoWindow: InfoWindow(
// // //           title: title,
// // //         ),
// // //         icon: icon,
// // //       ),
// // //     );
// // //   }

// // //   // Fetch directions between starting and ending locations
// // //   Future<Polyline?> fetchDirections() async {
// // //     if (_startingLocationCoordinates == null ||
// // //         _endingLocationCoordinates == null) {
// // //       debugPrint(
// // //           'Cannot fetch directions: Missing starting or ending location');
// // //       return null;
// // //     }

// // //     try {
// // //       final String url =
// // //           'https://maps.googleapis.com/maps/api/directions/json?origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}&key=$apikey';

// // //       final response = await http.get(Uri.parse(url));

// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);

// // //         if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
// // //           final List<LatLng> polylineCoordinates =
// // //               _decodePolyline(data['routes'][0]['overview_polyline']['points']);

// // //           _polyline = Polyline(
// // //             polylineId: const PolylineId('route'),
// // //             points: polylineCoordinates,
// // //             color: Colors.black,
// // //             width: 5,
// // //           );

// // //           debugPrint(
// // //               'Polyline created with ${polylineCoordinates.length} points');
// // //           return _polyline;
// // //         } else {
// // //           debugPrint('API Error: ${data['status']}');
// // //         }
// // //       } else {
// // //         debugPrint('HTTP Error: ${response.statusCode}');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error fetching directions: $e');
// // //     }

// // //     return null;
// // //   }

// // //   // Decode the polyline points
// // //   List<LatLng> _decodePolyline(String encoded) {
// // //     List<LatLng> polylineCoordinates = [];
// // //     int index = 0;
// // //     int len = encoded.length;
// // //     int lat = 0;
// // //     int lng = 0;

// // //     while (index < len) {
// // //       int b;
// // //       int shift = 0;
// // //       int result = 0;

// // //       do {
// // //         b = encoded.codeUnitAt(index) - 63;
// // //         index++;
// // //         result |= (b & 0x1f) << shift;
// // //         shift += 5;
// // //       } while (b >= 0x20);
// // //       lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

// // //       shift = 0;
// // //       result = 0;

// // //       do {
// // //         b = encoded.codeUnitAt(index) - 63;
// // //         index++;
// // //         result |= (b & 0x1f) << shift;
// // //         shift += 5;
// // //       } while (b >= 0x20);
// // //       lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

// // //       polylineCoordinates.add(
// // //         LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()),
// // //       );
// // //     }
// // //     return polylineCoordinates;
// // //   }

// // //   // //Add a marker for current location
// // //   // void addCurrentLocationMarker() {
// // //   //   if (_currentLocationCoordinates != null) {
// // //   //     _markers
// // //   //         .removeWhere((marker) => marker.markerId.value == 'current-location');
// // //   //     _markers.add(
// // //   //       Marker(
// // //   //         markerId: const MarkerId('current-location'),
// // //   //         position: _currentLocationCoordinates!,
// // //   //         infoWindow: const InfoWindow(
// // //   //           title: 'Current Location',
// // //   //           snippet: 'You are here',
// // //   //         ),
// // //   //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// // //   //       ),
// // //   //     );
// // //   //   }
// // //   // }

// // //   // Clear all markers and polylines
// // //   void clearMapData() {
// // //     _markers.clear();
// // //     _polyline = null;
// // //     _startingLocationCoordinates = null;
// // //     _endingLocationCoordinates = null;
// // //   }
// // // }

// // import 'dart:convert';
// // import 'dart:math';

// // import 'package:flutter/material.dart';
// // import 'package:geocoding/geocoding.dart' as geocoding;
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:location/location.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // class LocationRepository {
// //   static final LocationRepository _instance = LocationRepository._internal();

// //   factory LocationRepository() {
// //     return _instance;
// //   }

// //   LocationRepository._internal();

// //   // Add your Google Maps API key here
// //   static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

// //   // State variables
// //   bool _isLoading = false;
// //   List<dynamic> _placePredictions = [];
// //   LatLng? _startingLocationCoordinates;
// //   LatLng? _endingLocationCoordinates;
// //   LatLng? _currentLocationCoordinates;
// //   final Set<Marker> _markers = <Marker>{};
// //   Polyline? _polyline;

// //   // Getters for state
// //   bool get isLoading => _isLoading;

// //   List<dynamic> get placePredictions => _placePredictions;

// //   LatLng? get startingLocationCoordinates => _startingLocationCoordinates;

// //   LatLng? get endingLocationCoordinates => _endingLocationCoordinates;

// //   LatLng? get currentLocationCoordinates => _currentLocationCoordinates;

// //   Set<Marker> get markers => _markers;

// //   Polyline? get polyline => _polyline;

// //   // Setter for current location coordinates
// //   set currentLocationCoordinates(LatLng? coordinates) {
// //     _currentLocationCoordinates = coordinates;
// //     if (coordinates != null) {
// //       // addCurrentLocationMarker(); // Uncomment if you implement this method
// //     }
// //   }

// //   set startingLocationCoordinates(LatLng? coordinates) {
// //     _startingLocationCoordinates = coordinates;
// //     if (coordinates != null) {
// //       _updateMarker('starting-location', coordinates, 'Pickup Location');
// //     }
// //   }

// //   set endingLocationCoordinates(LatLng? coordinates) {
// //     _endingLocationCoordinates = coordinates;
// //     if (coordinates != null) {
// //       _updateMarker('ending-location', coordinates, 'Destination');
// //     }
// //   }

// //   // Method to set current location coordinates
// //   void setCurrentLocationCoordinates(LatLng coordinates) {
// //     _currentLocationCoordinates = coordinates;
// //     // addCurrentLocationMarker(); // Uncomment if you implement this method
// //   }

// //   void clearPolylines() {
// //     _polyline = null;
// //   }

// //   void clearLocationCoordinates() {
// //     startingLocationCoordinates = null;
// //     endingLocationCoordinates = null;
// //   }

// //   // Add a method to set starting location coordinates
// //   void setStartingLocationCoordinates(LatLng coordinates) {
// //     _startingLocationCoordinates = coordinates;
// //     _updateMarker('starting-location', coordinates, 'Pickup Location');
// //   }

// //   // Add a method to set ending location coordinates
// //   void setEndingLocationCoordinates(LatLng coordinates) {
// //     _endingLocationCoordinates = coordinates;
// //     _updateMarker('ending-location', coordinates, 'Destination');
// //   }

// //   void clearPlacePredictions() {
// //     _placePredictions = [];
// //   }

// //   // Fetch current location
// //   Future<LatLng?> getCurrentLocation() async {
// //     Location location = Location();

// //     try {
// //       // Check if location service is enabled
// //       bool serviceEnabled = await location.serviceEnabled();
// //       if (!serviceEnabled) {
// //         serviceEnabled = await location.requestService();
// //         if (!serviceEnabled) {
// //           debugPrint("Location services are disabled");
// //           return null;
// //         }
// //       }

// //       // Check and request location permission
// //       PermissionStatus permissionGranted = await location.hasPermission();
// //       if (permissionGranted == PermissionStatus.denied) {
// //         permissionGranted = await location.requestPermission();
// //         if (permissionGranted != PermissionStatus.granted &&
// //             permissionGranted != PermissionStatus.grantedLimited) {
// //           debugPrint("Location permission not granted");
// //           return null;
// //         }
// //       }

// //       // Get the current location data
// //       LocationData locationData = await location.getLocation();

// //       // Only proceed if we have valid coordinates
// //       if (locationData.latitude != null && locationData.longitude != null) {
// //         _currentLocationCoordinates =
// //             LatLng(locationData.latitude!, locationData.longitude!);
// //         return _currentLocationCoordinates;
// //       }
// //     } catch (e) {
// //       debugPrint("Error getting location: $e");
// //     }

// //     return null;
// //   }

// //   Future<String> getAddressFromLatLng(double latitude, double longitude) async {
// //     try {
// //       List<geocoding.Placemark> placemarks =
// //           await geocoding.placemarkFromCoordinates(latitude, longitude);
// //       if (placemarks.isNotEmpty) {
// //         geocoding.Placemark place = placemarks[0];
// //         String address = "";
// //         if (place.street != null && place.street!.isNotEmpty) {
// //           address += "${place.street}, ";
// //         }
// //         if (place.locality != null && place.locality!.isNotEmpty) {
// //           address += "${place.locality}, ";
// //         }
// //         if (place.administrativeArea != null &&
// //             place.administrativeArea!.isNotEmpty) {
// //           address += place.administrativeArea!;
// //         }
// //         return address.trim().endsWith(',')
// //             ? address.substring(0, address.length - 1)
// //             : address;
// //       }
// //     } catch (e) {
// //       debugPrint("Error getting address: $e");
// //     }
// //     return "Your Current Location";
// //   }

// //   // Place auto-complete suggestions
// //   Future<List<dynamic>> placeAutoComplete(String query) async {
// //     if (query.isEmpty) {
// //       _placePredictions = [];
// //       return _placePredictions;
// //     }

// //     _isLoading = true;

// //     try {
// //       final Uri uri = Uri.https(
// //         'maps.googleapis.com',
// //         '/maps/api/place/autocomplete/json',
// //         {
// //           'input': query,
// //           'key': apiKey,
// //           'components': 'country:bd', // Optional: restrict to Bangladesh
// //         },
// //       );

// //       final response = await http.get(uri);

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['status'] == 'OK') {
// //           _placePredictions = data['predictions'];
// //         } else {
// //           debugPrint('API Error: ${data['status']} - ${data['error_message'] ?? ""}');
// //           _placePredictions = [];
// //         }
// //       } else {
// //         debugPrint('HTTP Error: ${response.statusCode}');
// //         _placePredictions = [];
// //       }
// //     } catch (e) {
// //       debugPrint('Error in place autocomplete: $e');
// //       _placePredictions = [];
// //     } finally {
// //       _isLoading = false;
// //     }

// //     return _placePredictions;
// //   }

// //   // Fetch place details based on placeId
// //   Future<LatLng?> fetchPlaceDetails(String placeId, String locationType) async {
// //     if (placeId.isEmpty) {
// //       debugPrint('Empty placeId provided');
// //       return null;
// //     }

// //     try {
// //       final Uri uri = Uri.https(
// //         'maps.googleapis.com',
// //         '/maps/api/place/details/json',
// //         {
// //           'place_id': placeId,
// //           'fields': 'geometry,name,formatted_address',
// //           'key': apiKey,
// //         },
// //       );

// //       final response = await http.get(uri);

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);

// //         if (data['status'] == 'OK' && data['result'] != null) {
// //           final location = data['result']['geometry']['location'];
// //           LatLng locationCoordinates = LatLng(
// //             location['lat'].toDouble(),
// //             location['lng'].toDouble(),
// //           );

// //           if (locationType == 'starting') {
// //             startingLocationCoordinates = locationCoordinates;
// //           } else {
// //             endingLocationCoordinates = locationCoordinates;
// //           }

// //           // If both locations are set, fetch directions
// //           if (startingLocationCoordinates != null &&
// //               endingLocationCoordinates != null) {
// //             await fetchDirections();
// //           }

// //           return locationCoordinates;
// //         } else {
// //           debugPrint('API Error: ${data['status']}');
// //         }
// //       } else {
// //         debugPrint('HTTP Error: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching place details: $e');
// //     }

// //     return null;
// //   }

// //   // Helper to update a marker
// //   void _updateMarker(String markerId, LatLng position, String title) {
// //     _markers.removeWhere((marker) => marker.markerId.value == markerId);

// //     // Set different colors for different marker types
// //     BitmapDescriptor icon;
// //     if (markerId == 'starting-location') {
// //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
// //     } else if (markerId == 'ending-location') {
// //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
// //     } else {
// //       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
// //     }

// //     _markers.add(
// //       Marker(
// //         markerId: MarkerId(markerId),
// //         position: position,
// //         infoWindow: InfoWindow(title: title),
// //         icon: icon,
// //       ),
// //     );
// //   }

// //   // Fetch directions between starting and ending locations
// //   Future<Polyline?> fetchDirections() async {
// //     if (_startingLocationCoordinates == null ||
// //         _endingLocationCoordinates == null) {
// //       debugPrint('Cannot fetch directions: Missing starting or ending location');
// //       return null;
// //     }

// //     try {
// //       final String url =
// //           'https://maps.googleapis.com/maps/api/directions/json?'
// //           'origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}'
// //           '&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}'
// //           '&key=$apiKey'
// //           '&mode=driving'; // You can change mode to 'walking', 'bicycling', or 'transit'

// //       final response = await http.get(Uri.parse(url));

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);

// //         if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
// //           final points = data['routes'][0]['overview_polyline']['points'] as String;
// //           final List<LatLng> polylineCoordinates = _decodePolyline(points);

// //           _polyline = Polyline(
// //             polylineId: const PolylineId('route'),
// //             points: polylineCoordinates,
// //             color: Colors.blue,
// //             width: 5,
// //             startCap: Cap.roundCap,
// //             endCap: Cap.roundCap,
// //           );

// //           debugPrint('Polyline created with ${polylineCoordinates.length} points');
// //           return _polyline;
// //         } else {
// //           debugPrint('API Error: ${data['status']}');
// //         }
// //       } else {
// //         debugPrint('HTTP Error: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching directions: $e');
// //     }

// //     return null;
// //   }

// //   // Decode the polyline points
// //   List<LatLng> _decodePolyline(String encoded) {
// //     List<LatLng> polylineCoordinates = [];
// //     int index = 0;
// //     int len = encoded.length;
// //     int lat = 0;
// //     int lng = 0;

// //     while (index < len) {
// //       int b;
// //       int shift = 0;
// //       int result = 0;

// //       do {
// //         b = encoded.codeUnitAt(index++) - 63;
// //         result |= (b & 0x1f) << shift;
// //         shift += 5;
// //       } while (b >= 0x20);

// //       lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

// //       shift = 0;
// //       result = 0;

// //       do {
// //         b = encoded.codeUnitAt(index++) - 63;
// //         result |= (b & 0x1f) << shift;
// //         shift += 5;
// //       } while (b >= 0x20);

// //       lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

// //       polylineCoordinates.add(
// //         LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()),
// //       );
// //     }
// //     return polylineCoordinates;
// //   }

// //   // Add a marker for current location (optional - uncomment if needed)
// //   // void addCurrentLocationMarker() {
// //   //   if (_currentLocationCoordinates != null) {
// //   //     _markers.removeWhere((marker) => marker.markerId.value == 'current-location');
// //   //     _markers.add(
// //   //       Marker(
// //   //         markerId: const MarkerId('current-location'),
// //   //         position: _currentLocationCoordinates!,
// //   //         infoWindow: const InfoWindow(
// //   //           title: 'Current Location',
// //   //           snippet: 'You are here',
// //   //         ),
// //   //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// //   //       ),
// //   //     );
// //   //   }
// //   // }

// //   // Get distance between two points in meters
// //   double calculateDistance(LatLng start, LatLng end) {
// //     const double earthRadius = 6371000; // meters

// //     double lat1 = start.latitude * (pi / 180);
// //     double lon1 = start.longitude * (pi / 180);
// //     double lat2 = end.latitude * (pi / 180);
// //     double lon2 = end.longitude * (pi / 180);

// //     double dLat = lat2 - lat1;
// //     double dLon = lon2 - lon1;

// //     double a = sin(dLat / 2) * sin(dLat / 2) +
// //         cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
// //     double c = 2 * atan2(sqrt(a), sqrt(1 - a));

// //     return earthRadius * c;
// //   }

// //   // Clear all markers and polylines
// //   void clearMapData() {
// //     _markers.clear();
// //     _polyline = null;
// //     _startingLocationCoordinates = null;
// //     _endingLocationCoordinates = null;
// //   }

// //   // Dispose method to clean up resources
// //   void dispose() {
// //     clearMapData();
// //     _placePredictions.clear();
// //     _currentLocationCoordinates = null;
// //   }
// // }

// import 'dart:convert';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class LocationRepository {
//   static final LocationRepository _instance = LocationRepository._internal();

//   factory LocationRepository() {
//     return _instance;
//   }

//   LocationRepository._internal();

//   // Add your Google Maps API key here
//   static const String apiKey = 'AIzaSyBFi80uuJIWkkLCpodFa8oXmD8XD_h8LMc';

//   // State variables
//   bool _isLoading = false;
//   List<dynamic> _placePredictions = [];
//   LatLng? _startingLocationCoordinates;
//   LatLng? _endingLocationCoordinates;
//   LatLng? _currentLocationCoordinates;
//   final Set<Marker> _markers = <Marker>{};
//   Polyline? _polyline;

//   // Getters for state
//   bool get isLoading => _isLoading;

//   List<dynamic> get placePredictions => _placePredictions;

//   LatLng? get startingLocationCoordinates => _startingLocationCoordinates;

//   LatLng? get endingLocationCoordinates => _endingLocationCoordinates;

//   LatLng? get currentLocationCoordinates => _currentLocationCoordinates;

//   Set<Marker> get markers => _markers;

//   Polyline? get polyline => _polyline;

//   // Setter for current location coordinates
//   set currentLocationCoordinates(LatLng? coordinates) {
//     _currentLocationCoordinates = coordinates;
//     if (coordinates != null) {
//       // addCurrentLocationMarker(); // Uncomment if you implement this method
//     }
//   }

//   set startingLocationCoordinates(LatLng? coordinates) {
//     _startingLocationCoordinates = coordinates;
//     if (coordinates != null) {
//       _updateMarker('starting-location', coordinates, 'Pickup Location');
//     }
//   }

//   set endingLocationCoordinates(LatLng? coordinates) {
//     _endingLocationCoordinates = coordinates;
//     if (coordinates != null) {
//       _updateMarker('ending-location', coordinates, 'Destination');
//     }
//   }

//   // Method to set current location coordinates
//   void setCurrentLocationCoordinates(LatLng coordinates) {
//     _currentLocationCoordinates = coordinates;
//     // addCurrentLocationMarker(); // Uncomment if you implement this method
//   }

//   void clearPolylines() {
//     _polyline = null;
//   }

//   void clearLocationCoordinates() {
//     startingLocationCoordinates = null;
//     endingLocationCoordinates = null;
//   }

//   // Add a method to set starting location coordinates
//   void setStartingLocationCoordinates(LatLng coordinates) {
//     _startingLocationCoordinates = coordinates;
//     _updateMarker('starting-location', coordinates, 'Pickup Location');
//   }

//   // Add a method to set ending location coordinates
//   void setEndingLocationCoordinates(LatLng coordinates) {
//     _endingLocationCoordinates = coordinates;
//     _updateMarker('ending-location', coordinates, 'Destination');
//   }

//   void clearPlacePredictions() {
//     _placePredictions = [];
//   }

//   // Fetch current location using Geolocator
//   Future<LatLng?> getCurrentLocation() async {
//     try {
//       // Check if location service is enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         debugPrint("Location services are disabled");
//         return null;
//       }

//       // Check location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           debugPrint("Location permissions are denied");
//           return null;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         debugPrint("Location permissions are permanently denied");
//         return null;
//       }

//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       _currentLocationCoordinates =
//           LatLng(position.latitude, position.longitude);
//       return _currentLocationCoordinates;
//     } catch (e) {
//       debugPrint("Error getting location: $e");
//       return null;
//     }
//   }

//   Future<String> getAddressFromLatLng(double latitude, double longitude) async {
//     try {
//       List<geocoding.Placemark> placemarks =
//           await geocoding.placemarkFromCoordinates(latitude, longitude);
//       if (placemarks.isNotEmpty) {
//         geocoding.Placemark place = placemarks[0];
//         String address = "";
//         if (place.street != null && place.street!.isNotEmpty) {
//           address += "${place.street}, ";
//         }
//         if (place.locality != null && place.locality!.isNotEmpty) {
//           address += "${place.locality}, ";
//         }
//         if (place.administrativeArea != null &&
//             place.administrativeArea!.isNotEmpty) {
//           address += place.administrativeArea!;
//         }
//         return address.trim().endsWith(',')
//             ? address.substring(0, address.length - 1)
//             : address;
//       }
//     } catch (e) {
//       debugPrint("Error getting address: $e");
//     }
//     return "Your Current Location";
//   }

//   // Place auto-complete suggestions
//   Future<List<dynamic>> placeAutoComplete(String query) async {
//     if (query.isEmpty) {
//       _placePredictions = [];
//       return _placePredictions;
//     }

//     _isLoading = true;

//     try {
//       final Uri uri = Uri.https(
//         'maps.googleapis.com',
//         '/maps/api/place/autocomplete/json',
//         {
//           'input': query,
//           'key': apiKey,
//           'components': 'country:bd', // Optional: restrict to Bangladesh
//         },
//       );

//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           _placePredictions = data['predictions'];
//         } else {
//           debugPrint(
//               'API Error: ${data['status']} - ${data['error_message'] ?? ""}');
//           _placePredictions = [];
//         }
//       } else {
//         debugPrint('HTTP Error: ${response.statusCode}');
//         _placePredictions = [];
//       }
//     } catch (e) {
//       debugPrint('Error in place autocomplete: $e');
//       _placePredictions = [];
//     } finally {
//       _isLoading = false;
//     }

//     return _placePredictions;
//   }

//   // Fetch place details based on placeId
//   Future<LatLng?> fetchPlaceDetails(String placeId, String locationType) async {
//     if (placeId.isEmpty) {
//       debugPrint('Empty placeId provided');
//       return null;
//     }

//     try {
//       final Uri uri = Uri.https(
//         'maps.googleapis.com',
//         '/maps/api/place/details/json',
//         {
//           'place_id': placeId,
//           'fields': 'geometry,name,formatted_address',
//           'key': apiKey,
//         },
//       );

//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == 'OK' && data['result'] != null) {
//           final location = data['result']['geometry']['location'];
//           LatLng locationCoordinates = LatLng(
//             location['lat'].toDouble(),
//             location['lng'].toDouble(),
//           );

//           if (locationType == 'starting') {
//             startingLocationCoordinates = locationCoordinates;
//           } else {
//             endingLocationCoordinates = locationCoordinates;
//           }

//           // If both locations are set, fetch directions
//           if (startingLocationCoordinates != null &&
//               endingLocationCoordinates != null) {
//             await fetchDirections();
//           }

//           return locationCoordinates;
//         } else {
//           debugPrint('API Error: ${data['status']}');
//         }
//       } else {
//         debugPrint('HTTP Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching place details: $e');
//     }

//     return null;
//   }

//   // Helper to update a marker
//   void _updateMarker(String markerId, LatLng position, String title) {
//     _markers.removeWhere((marker) => marker.markerId.value == markerId);

//     // Set different colors for different marker types
//     BitmapDescriptor icon;
//     if (markerId == 'starting-location') {
//       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//     } else if (markerId == 'ending-location') {
//       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//     } else {
//       icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
//     }

//     _markers.add(
//       Marker(
//         markerId: MarkerId(markerId),
//         position: position,
//         infoWindow: InfoWindow(title: title),
//         icon: icon,
//       ),
//     );
//   }

//   // Fetch directions between starting and ending locations
//   Future<Polyline?> fetchDirections() async {
//     if (_startingLocationCoordinates == null ||
//         _endingLocationCoordinates == null) {
//       debugPrint(
//           'Cannot fetch directions: Missing starting or ending location');
//       return null;
//     }

//     try {
//       final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
//           'origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}'
//           '&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}'
//           '&key=$apiKey'
//           '&mode=driving'; // You can change mode to 'walking', 'bicycling', or 'transit'

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
//           final points =
//               data['routes'][0]['overview_polyline']['points'] as String;
//           final List<LatLng> polylineCoordinates = _decodePolyline(points);

//           _polyline = Polyline(
//             polylineId: const PolylineId('route'),
//             points: polylineCoordinates,
//             color: Colors.blue,
//             width: 5,
//             startCap: Cap.roundCap,
//             endCap: Cap.roundCap,
//           );

//           debugPrint(
//               'Polyline created with ${polylineCoordinates.length} points');
//           return _polyline;
//         } else {
//           debugPrint('API Error: ${data['status']}');
//         }
//       } else {
//         debugPrint('HTTP Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching directions: $e');
//     }

//     return null;
//   }

//   // Decode the polyline points
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> polylineCoordinates = [];
//     int index = 0;
//     int len = encoded.length;
//     int lat = 0;
//     int lng = 0;

//     while (index < len) {
//       int b;
//       int shift = 0;
//       int result = 0;

//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);

//       lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

//       shift = 0;
//       result = 0;

//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);

//       lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

//       polylineCoordinates.add(
//         LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()),
//       );
//     }
//     return polylineCoordinates;
//   }

//   // Add a marker for current location (optional - uncomment if needed)
//   // void addCurrentLocationMarker() {
//   //   if (_currentLocationCoordinates != null) {
//   //     _markers.removeWhere((marker) => marker.markerId.value == 'current-location');
//   //     _markers.add(
//   //       Marker(
//   //         markerId: const MarkerId('current-location'),
//   //         position: _currentLocationCoordinates!,
//   //         infoWindow: const InfoWindow(
//   //           title: 'Current Location',
//   //           snippet: 'You are here',
//   //         ),
//   //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//   //       ),
//   //     );
//   //   }
//   // }

//   // Get distance between two points in meters
//   double calculateDistance(LatLng start, LatLng end) {
//     const double earthRadius = 6371000; // meters

//     double lat1 = start.latitude * (math.pi / 180);
//     double lon1 = start.longitude * (math.pi / 180);
//     double lat2 = end.latitude * (math.pi / 180);
//     double lon2 = end.longitude * (math.pi / 180);

//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;

//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(lat1) *
//             math.cos(lat2) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

//     return earthRadius * c;
//   }

//   // Get distance in kilometers with formatting
//   String getFormattedDistance(LatLng start, LatLng end) {
//     double distanceInMeters = calculateDistance(start, end);
//     if (distanceInMeters < 1000) {
//       return "${distanceInMeters.toStringAsFixed(0)} m";
//     } else {
//       return "${(distanceInMeters / 1000).toStringAsFixed(2)} km";
//     }
//   }

//   // Clear all markers and polylines
//   void clearMapData() {
//     _markers.clear();
//     _polyline = null;
//     _startingLocationCoordinates = null;
//     _endingLocationCoordinates = null;
//   }

//   // Dispose method to clean up resources
//   void dispose() {
//     clearMapData();
//     _placePredictions.clear();
//     _currentLocationCoordinates = null;
//   }
// }
