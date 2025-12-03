// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:kaz_bd/constants/text_font_style.dart';
// import 'package:kaz_bd/gen/colors.gen.dart';

// import '../../../../routes/routes.dart';

// ///Arguments needs to be send to Service Preview Screen
// // arguments: {
// //                             'userId': userId,
// //                             'bookingDateTime': bookingDateTime,
// //                             'lat': 23.78070895187634,
// //                             'long': 90.40762509309513,
// //                             'address': "address address V2",
// //                           },

// class SearchLocationScreen extends StatefulWidget {
//   const SearchLocationScreen({super.key});

//   @override
//   State<SearchLocationScreen> createState() => _SearchLocationScreenState();
// }

// class _SearchLocationScreenState extends State<SearchLocationScreen> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   // Default to Bangladesh coordinates
//   static const CameraPosition _kBangladesh = CameraPosition(
//     target: LatLng(23.6850, 90.3563), // Center of Bangladesh
//     zoom: 12.0,
//   );

//   Set<Marker> _markers = <Marker>{};
//   String _selectedAddress = "Select a location on the map";

//   @override
//   void initState() {
//     super.initState();
//     _initCurrentLocation();
//   }

//   Future<void> _initCurrentLocation() async {
//     try {
//       // Check permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         // Use default Bangladesh location if permission denied
//         debugPrint("Location permissions denied");
//         return;
//       }

//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//         ),
//       );

//       // Wait for the map controller to be ready and then move to current location
//       _controller.future.then((GoogleMapController controller) async {
//         await controller.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15.0,
//             ),
//           ),
//         );
//       });
//     } catch (e) {
//       // If location access fails, stick with default Bangladesh location
//       debugPrint("Location access failed: $e");
//     }
//   }

//   Future<void> _goToDhaka() async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         const CameraPosition(
//           target: LatLng(23.8103, 90.4125), // Dhaka coordinates
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }

//   void _onMapTapped(LatLng position) async {
//     // Remove existing markers
//     setState(() {
//       _markers.clear();
//     });

//     // Add a marker at the tapped location
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: position,
//           infoWindow: const InfoWindow(title: 'Selected Location'),
//         ),
//       );
//     });

//     // Get address from coordinates using geocoding
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         String fullAddress =
//             "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
//                 .replaceAll(", ,", ", ")
//                 .replaceAll(RegExp(r', $'), '');
//         setState(() {
//           _selectedAddress = fullAddress.isNotEmpty
//               ? fullAddress
//               : "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
//         });
//       } else {
//         setState(() {
//           _selectedAddress =
//               "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _selectedAddress =
//             "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     final bookingDateTime = arguments?['bookingDateTime'] ?? '';
//     final providerId = arguments?['providerId'] ?? '';
//     final latDynamic = arguments?['lat'];
//     final longDynamic = arguments?['long'];

//     // Parse initial coordinates from arguments
//     double? initialLat;
//     double? initialLng;

//     if (latDynamic != null) {
//       if (latDynamic is String) {
//         initialLat = double.tryParse(latDynamic);
//       } else if (latDynamic is num) {
//         initialLat = latDynamic.toDouble();
//       }
//     }

//     if (longDynamic != null) {
//       if (longDynamic is String) {
//         initialLng = double.tryParse(longDynamic);
//       } else if (longDynamic is num) {
//         initialLng = longDynamic.toDouble();
//       }
//     }

//     // Default to Bangladesh center, but this will be updated when current location is fetched
//     CameraPosition initialPosition = _kBangladesh;
//     if (initialLat != null && initialLng != null) {
//       // Use coordinates passed from previous screen if available
//       initialPosition = CameraPosition(
//         target: LatLng(initialLat, initialLng),
//         zoom: 15.0,
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Select Location",
//           style: TextFontStyle.headline18w700c000000StyleSatoshi,
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//       ),
//       body: Column(
//         children: [
//           // Selected address display
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: AppColors.cFFFFFF,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Selected Location:",
//                   style: TextFontStyle.headline14w500c000000StyleSatoshi,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _selectedAddress,
//                   style: TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),

//           // Map container
//           Expanded(
//             child: GoogleMap(
//               mapType: MapType.normal,
//               initialCameraPosition: initialPosition,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               onLongPress:
//                   _onMapTapped, // Allow user to select location by long pressing
//               markers: _markers,
//               myLocationButtonEnabled: true,
//               zoomControlsEnabled: true,
//               // Enable the myLocation functionality (this may help with platform view registration)
//               myLocationEnabled: true,
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToDhaka,
//         label: const Text('Go to Dhaka'),
//         icon: const Icon(Icons.location_city),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: () {
//             // Navigate to service preview with selected location data
//             if (_markers.isNotEmpty) {
//               final selectedMarker = _markers.first;
//               Get.toNamed(
//                 Routes.servicePreviewScreen,
//                 arguments: {
//                   'userId': providerId,
//                   'bookingDateTime': bookingDateTime,
//                   'lat': selectedMarker.position.latitude,
//                   'long': selectedMarker.position.longitude,
//                   'address': _selectedAddress,
//                 },
//               );

//               log('User ID : $providerId');
//               log('Booking Date Time : $bookingDateTime');
//               log('Latitude : ${selectedMarker.position.latitude}');
//               log('Longitude : ${selectedMarker.position.longitude}');
//               log('Address : $_selectedAddress');
//             } else {
//               Get.snackbar(
//                 'Location Required',
//                 'Please select a location on the map',
//                 backgroundColor: AppColors.cee3333,
//                 colorText: AppColors.cFFFFFF,
//               );
//             }
//           },
//           child: const Text('Confirm Location'),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';

import '../../../../routes/routes.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Default to Bangladesh coordinates (fallback)
  static const CameraPosition _kBangladesh = CameraPosition(
    target: LatLng(23.6850, 90.3563), // Center of Bangladesh
    zoom: 12.0,
  );

  Set<Marker> _markers = <Marker>{};
  String _selectedAddress = "Getting your current location...";
  bool _isLoadingLocation = true;
  LatLng? _currentUserLocation;
  LatLng? _selectedLocation;
  bool _hasInitialLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _selectedAddress = "Location services are disabled";
          _isLoadingLocation = false;
        });
        // Show a dialog to enable location services
        _showLocationServicesDialog();
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _selectedAddress = "Location permissions denied";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _selectedAddress = "Location permissions permanently denied";
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Store the current location
      _currentUserLocation = LatLng(position.latitude, position.longitude);
      _selectedLocation = _currentUserLocation; // Set as initial selection

      // Get address from coordinates
      await _getAddressFromLatLng(_currentUserLocation!);

      // Add marker for current location
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentUserLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Your Current Location'),
          ),
        );
        _isLoadingLocation = false;
      });

      // Move camera to current location when map is ready
      _moveToCurrentLocation();
    } catch (e) {
      debugPrint("Location access failed: $e");
      setState(() {
        _selectedAddress = "Unable to get your location: ${e.toString()}";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentUserLocation != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentUserLocation!, zoom: 15.0),
        ),
      );
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
                .replaceAll(", ,", ", ")
                .replaceAll(RegExp(r', $'), '');

        setState(() {
          _selectedAddress = fullAddress.isNotEmpty
              ? fullAddress
              : "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        });
      } else {
        setState(() {
          _selectedAddress =
              "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress =
            "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
      });
    }
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text(
          "Please enable location services to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng position) async {
    // Clear existing markers
    setState(() {
      _markers.clear();
    });

    // Add new marker for selected location
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
      _selectedLocation = position;
    });

    // Get address for the selected location
    await _getAddressFromLatLng(position);
  }

  void _goToCurrentLocation() async {
    if (_currentUserLocation != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentUserLocation!, zoom: 15.0),
        ),
      );

      // Also update the selection to current location
      _onMapTapped(_currentUserLocation!);
    } else {
      await _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final bookingDateTime = arguments?['bookingDateTime'] ?? '';
    final providerId = arguments?['providerId'] ?? '';

    // Determine initial camera position
    CameraPosition initialPosition;
    if (_currentUserLocation != null) {
      // Use current user location if available
      initialPosition = CameraPosition(
        target: _currentUserLocation!,
        zoom: 15.0,
      );
    } else {
      // Use coordinates from arguments or default to Bangladesh
      final latDynamic = arguments?['lat'];
      final longDynamic = arguments?['long'];
      double? initialLat;
      double? initialLng;

      if (latDynamic != null) {
        if (latDynamic is String) {
          initialLat = double.tryParse(latDynamic);
        } else if (latDynamic is num) {
          initialLat = latDynamic.toDouble();
        }
      }

      if (longDynamic != null) {
        if (longDynamic is String) {
          initialLng = double.tryParse(longDynamic);
        } else if (longDynamic is num) {
          initialLng = longDynamic.toDouble();
        }
      }

      if (initialLat != null && initialLng != null) {
        initialPosition = CameraPosition(
          target: LatLng(initialLat, initialLng),
          zoom: 15.0,
        );
      } else {
        initialPosition = _kBangladesh;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Location",
          style: TextFontStyle.headline18w700c000000StyleSatoshi,
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: _goToCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: "Go to my current location",
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected address display
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.cFFFFFF,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Location:",
                  style: TextFontStyle.headline14w500c000000StyleSatoshi,
                ),
                const SizedBox(height: 8),
                _isLoadingLocation
                    ? Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 10),
                          Text(
                            "Getting your location...",
                            style:
                                TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
                          ),
                        ],
                      )
                    : Text(
                        _selectedAddress,
                        style: TextFontStyle.headline14w500c6a6a6aStyleSatoshi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),

          // Map container
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    // If we already have current location, move camera to it
                    if (_currentUserLocation != null && !_hasInitialLocation) {
                      _hasInitialLocation = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _moveToCurrentLocation();
                      });
                    }
                  },
                  onLongPress: _onMapTapped,
                  markers: _markers,
                  myLocationButtonEnabled: false, // We'll use our own button
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                ),

                // Current location button overlay
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: FloatingActionButton.small(
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCurrentLocation,
        label: const Text('My Location'),
        icon: const Icon(Icons.location_searching),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _selectedLocation == null
              ? null
              : () {
                  // Navigate to service preview with selected location data
                  Get.toNamed(
                    Routes.servicePreviewScreen,
                    arguments: {
                      'userId': providerId,
                      'bookingDateTime': bookingDateTime,
                      'lat': _selectedLocation!.latitude,
                      'long': _selectedLocation!.longitude,
                      'address': _selectedAddress,
                    },
                  );

                  log('User ID : $providerId');
                  log('Booking Date Time : $bookingDateTime');
                  log('Latitude : ${_selectedLocation!.latitude}');
                  log('Longitude : ${_selectedLocation!.longitude}');
                  log('Address : $_selectedAddress');
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedLocation == null
                ? Colors.grey
                : AppColors.c5c5c5c,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            _selectedLocation == null
                ? "Select a Location First"
                : "Confirm Location",
            style: TextStyle(
              color: _selectedLocation == null
                  ? Colors.grey[600]
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
