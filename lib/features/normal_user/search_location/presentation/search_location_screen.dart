import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

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
  LatLng? _currentUserLocation; // Just for showing where user is
  LatLng? _selectedLocation; // For the actual booking selection
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

      // Store the current location (just for display)
      _currentUserLocation = LatLng(position.latitude, position.longitude);

      // Get address from coordinates
      await _getAddressFromLatLng(_currentUserLocation!);

      // Add BLUE marker for current location (information only)
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentUserLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: 'Your Current Location',
              snippet: _selectedAddress,
            ),
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

    // Get address for the selected location
    String addressText =
        "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";

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

        addressText = fullAddress.isNotEmpty ? fullAddress : addressText;
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }

    // Update the address display
    setState(() {
      _selectedAddress = addressText;
    });

    // Add RED marker for selected location (for booking) with address in InfoWindow
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed, // RED for selected location
          ),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: addressText, // Address shows here in InfoWindow
          ),
        ),
      );
      _selectedLocation = position; // User explicitly selected this
    });
  }

  void _goToCurrentLocation() async {
    if (_currentUserLocation != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentUserLocation!, zoom: 15.0),
        ),
      );

      // Show a message that they need to tap to select
      Get.snackbar(
        'Tap to Select',
        'Long press on the map to select this location',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
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
                  onLongPress: _onMapTapped, // User MUST long press to select
                  markers: _markers,
                  myLocationButtonEnabled: false, // Using custom button
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
                  bottom: 120.h,
                  right: 10.w,
                  child: FloatingActionButton.small(
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),

                // Conditionally show the Confirm Location button
                if (_selectedLocation != null)
                  Positioned(
                    bottom: 20.h,
                    right: 50.w,
                    left: 50.w,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      padding: EdgeInsets.only(
                        left: UIHelper.kDefaulutPadding(),
                        right: UIHelper.kDefaulutPadding(),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
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
                          backgroundColor: AppColors.c5c5c5c,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          "Confirm Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // Optional: Show a hint when no location is selected
      bottomNavigationBar: Container(
        height: 50.h,
        width: 1.sw,
        color: Colors.transparent,
      ),
    );
  }
}
