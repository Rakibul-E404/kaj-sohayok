import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../routes/routes.dart';

// ============================
// LOCATION PERMISSION SERVICE
// ============================
class LocationPermissionService {
  static LocationPermissionService? _instance;

  LocationPermissionService._internal();

  static LocationPermissionService get instance {
    _instance ??= LocationPermissionService._internal();
    return _instance!;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission with proper handling for both platforms
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Comprehensive method to ensure location permission is granted
  /// Returns true if permission is granted, false otherwise
  Future<bool> ensureLocationPermission({
    bool showDialog = true,
    String? customMessage,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showDialog) {
          _showLocationServiceDialog();
        }
        return false;
      }

      // Check current permission status
      LocationPermission permission = await checkPermission();

      // Handle denied permission
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();

        // If still denied after request
        if (permission == LocationPermission.denied) {
          if (showDialog) {
            _showPermissionDeniedDialog(customMessage);
          }
          return false;
        }
      }

      // Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        if (showDialog) {
          _showPermissionPermanentlyDeniedDialog();
        }
        return false;
      }

      // Permission granted (whileInUse or always)
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      if (showDialog) {
        _showErrorDialog(e.toString());
      }
      return false;
    }
  }

  /// Get current position with permission check
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool requestPermission = true,
  }) async {
    try {
      if (requestPermission) {
        bool hasPermission = await ensureLocationPermission();
        if (!hasPermission) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      return null;
    }
  }

  /// Show dialog when location services are disabled
  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable location services in your device settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show dialog when permission is denied
  void _showPermissionDeniedDialog(String? customMessage) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(
          customMessage ??
              'This app needs location permission to provide location-based services. Please grant location permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await requestPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show dialog when permission is permanently denied
  void _showPermissionPermanentlyDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Permanently Denied'),
        content: const Text(
          'Location permission has been permanently denied. Please enable it manually in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Geolocator.openAppSettings();
            },
            child: const Text('App Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show error dialog
  void _showErrorDialog(String error) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Error'),
        content: Text('An error occurred while accessing location: $error'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ============================
// LOCATION REPOSITORY
// ============================
class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();

  factory LocationRepository() {
    return _instance;
  }

  LocationRepository._internal();

  // Google Maps API key
  static const String apiKey = 'AIzaSyDByTL-51tHLFMJgUTyHe0nT3-qhD2i9Mc';
  // static const String apiKey = 'AIzaSyDjwPmy5gPopQRKK5zCEa-_0u18e8Lmgi';

  // Place auto-complete suggestions
  Future<List<dynamic>> placeAutoComplete(String query) async {
    debugPrint('🔍 [PLACE AUTOCOMPLETE] Starting search for query: "$query"');

    if (query.isEmpty) {
      debugPrint('⚠️ [PLACE AUTOCOMPLETE] Empty query, returning empty list');
      return [];
    }

    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': apiKey,
          'components': 'country:bd', // Restrict to Bangladesh
          'types': 'geocode|establishment', // Add types for better results
          'language': 'en', // English results
        },
      );

      debugPrint(
          '🌐 [PLACE AUTOCOMPLETE] Making API request to: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint(
          '📡 [PLACE AUTOCOMPLETE] Response status: ${response.statusCode}');
      debugPrint(
          '📦 [PLACE AUTOCOMPLETE] Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        final errorMessage = data['error_message'];

        debugPrint('✅ [PLACE AUTOCOMPLETE] API Status: $status');

        if (errorMessage != null) {
          debugPrint('❌ [PLACE AUTOCOMPLETE] API Error Message: $errorMessage');
        }

        if (status == 'OK') {
          final predictions = data['predictions'];
          debugPrint(
              '🎯 [PLACE AUTOCOMPLETE] Found ${predictions.length} predictions');

          if (predictions.isNotEmpty) {
            for (var i = 0; i < predictions.length; i++) {
              final prediction = predictions[i];
              debugPrint(
                  '   ${i + 1}. ${prediction['description']} (ID: ${prediction['place_id']})');
            }
          }

          return predictions;
        } else if (status == 'ZERO_RESULTS') {
          debugPrint(
              '🔍 [PLACE AUTOCOMPLETE] No results found for query: "$query"');
          return [];
        } else {
          debugPrint(
              '❌ [PLACE AUTOCOMPLETE] API Error: $status - ${errorMessage ?? "No error message"}');

          // Log the full response for debugging
          debugPrint('📄 [PLACE AUTOCOMPLETE] Full response: ${response.body}');

          return [];
        }
      } else {
        debugPrint('❌ [PLACE AUTOCOMPLETE] HTTP Error: ${response.statusCode}');
        debugPrint('📄 [PLACE AUTOCOMPLETE] Response: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('💥 [PLACE AUTOCOMPLETE] Exception occurred: $e');
      debugPrint('📝 [PLACE AUTOCOMPLETE] Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Fetch place details based on placeId
  Future<LatLng?> fetchPlaceDetails(String placeId) async {
    debugPrint('📍 [PLACE DETAILS] Fetching details for placeId: $placeId');

    if (placeId.isEmpty) {
      debugPrint('⚠️ [PLACE DETAILS] Empty placeId provided');
      return null;
    }

    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'geometry,name,formatted_address',
          'key': apiKey,
        },
      );

      debugPrint('🌐 [PLACE DETAILS] Making API request to: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('📡 [PLACE DETAILS] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        debugPrint('✅ [PLACE DETAILS] API Status: $status');

        if (status == 'OK' && data['result'] != null) {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'].toDouble();
          final lng = location['lng'].toDouble();

          debugPrint(
              '🎯 [PLACE DETAILS] Retrieved coordinates: Lat: $lat, Lng: $lng');
          debugPrint(
              '🏠 [PLACE DETAILS] Place name: ${data['result']['name']}');
          debugPrint(
              '📫 [PLACE DETAILS] Address: ${data['result']['formatted_address']}');

          return LatLng(lat, lng);
        } else {
          debugPrint('❌ [PLACE DETAILS] API Error: $status');
          debugPrint('📄 [PLACE DETAILS] Response: ${response.body}');
        }
      } else {
        debugPrint('❌ [PLACE DETAILS] HTTP Error: ${response.statusCode}');
        debugPrint('📄 [PLACE DETAILS] Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 [PLACE DETAILS] Exception occurred: $e');
      debugPrint('📝 [PLACE DETAILS] Stack trace: ${StackTrace.current}');
    }

    return null;
  }
}

// ============================
// PLACE AUTOCOMPLETE WIDGET
// ============================
class PlaceAutocompleteWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String placeId, String description, {bool isCurrentLocation})
      onPlaceSelected;
  final bool showCurrentLocation;
  final String? currentLocationAddress;
  final Widget? prefixIcon;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxSuggestionsHeight;
  final int? maxSuggestions;
  final bool enabled;
  final FocusNode? focusNode;

  const PlaceAutocompleteWidget({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onPlaceSelected,
    this.showCurrentLocation = false,
    this.currentLocationAddress,
    this.prefixIcon,
    this.decoration,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.maxSuggestionsHeight = 200,
    this.maxSuggestions,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  State<PlaceAutocompleteWidget> createState() =>
      _PlaceAutocompleteWidgetState();
}

class _PlaceAutocompleteWidgetState extends State<PlaceAutocompleteWidget> {
  final LocationRepository _locationRepository = LocationRepository();
  late FocusNode _focusNode;

  List<dynamic> _predictions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isDisposed = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [AUTOCOMPLETE WIDGET] Initializing...');

    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && mounted && !_isDisposed) {
        debugPrint('🎯 [AUTOCOMPLETE WIDGET] Focus gained');
        _handleFocus();
      } else if (!_focusNode.hasFocus && mounted && !_isDisposed) {
        debugPrint('👋 [AUTOCOMPLETE WIDGET] Focus lost');
        _handleUnfocus();
      }
    });

    // Listen to controller changes for real-time search
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Cancel previous timer
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    // Start new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        final query = widget.controller.text;
        debugPrint('⌨️ [AUTOCOMPLETE WIDGET] Text changed: "$query"');
        _searchPlaces(query);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🗑️ [AUTOCOMPLETE WIDGET] Disposing...');
    _isDisposed = true;

    // Cancel debounce timer
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    // Remove controller listener
    widget.controller.removeListener(_onTextChanged);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocus() {
    debugPrint('👁️ [AUTOCOMPLETE WIDGET] Handling focus');

    if (widget.showCurrentLocation && widget.currentLocationAddress != null) {
      debugPrint('📍 [AUTOCOMPLETE WIDGET] Showing current location option');

      setState(() {
        _showSuggestions = true;
        _predictions = [
          {
            'place_id': 'current_location',
            'description': widget.currentLocationAddress!,
            'is_current_location': true,
          }
        ];
      });
    } else {
      // If there's text in the controller, trigger search
      if (widget.controller.text.isNotEmpty) {
        _searchPlaces(widget.controller.text);
      }
    }
  }

  void _handleUnfocus() {
    debugPrint('🙈 [AUTOCOMPLETE WIDGET] Handling unfocus');

    // Delay hiding suggestions to allow for tap events
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _showSuggestions = false;
          _predictions = [];
        });
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    debugPrint('🔍 [AUTOCOMPLETE WIDGET] Search called with query: "$query"');

    if (_isDisposed || !mounted) {
      debugPrint(
          '⚠️ [AUTOCOMPLETE WIDGET] Widget disposed or not mounted, aborting');
      return;
    }

    if (query.isEmpty) {
      debugPrint('📭 [AUTOCOMPLETE WIDGET] Query is empty');

      setState(() {
        _predictions =
            widget.showCurrentLocation && widget.currentLocationAddress != null
                ? [
                    {
                      'place_id': 'current_location',
                      'description': widget.currentLocationAddress!,
                      'is_current_location': true,
                    }
                  ]
                : [];
        _isLoading = false;
        _showSuggestions = _predictions.isNotEmpty;

        if (_showSuggestions) {
          debugPrint(
              '📍 [AUTOCOMPLETE WIDGET] Showing ${_predictions.length} current location suggestions');
        }
      });
      return;
    }

    debugPrint('⏳ [AUTOCOMPLETE WIDGET] Starting search for: "$query"');

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      debugPrint('📞 [AUTOCOMPLETE WIDGET] Calling repository for predictions');
      final predictions = await _locationRepository.placeAutoComplete(query);

      if (_isDisposed || !mounted) {
        debugPrint('⚠️ [AUTOCOMPLETE WIDGET] Widget disposed during API call');
        return;
      }

      debugPrint(
          '📊 [AUTOCOMPLETE WIDGET] Received ${predictions.length} predictions from API');

      setState(() {
        List<dynamic> finalPredictions = [];

        // Add current location option if enabled
        if (widget.showCurrentLocation &&
            widget.currentLocationAddress != null) {
          debugPrint('📍 [AUTOCOMPLETE WIDGET] Adding current location option');
          finalPredictions.add({
            'place_id': 'current_location',
            'description': widget.currentLocationAddress!,
            'is_current_location': true,
          });
        }

        // Add search predictions
        debugPrint(
            '➕ [AUTOCOMPLETE WIDGET] Adding ${predictions.length} search predictions');
        finalPredictions.addAll(predictions);

        // Limit suggestions if specified
        if (widget.maxSuggestions != null &&
            finalPredictions.length > widget.maxSuggestions!) {
          finalPredictions =
              finalPredictions.take(widget.maxSuggestions!).toList();
          debugPrint(
              '✂️ [AUTOCOMPLETE WIDGET] Limited to ${widget.maxSuggestions} suggestions');
        }

        _predictions = finalPredictions;
        _isLoading = false;

        debugPrint(
            '✅ [AUTOCOMPLETE WIDGET] Now showing ${_predictions.length} total suggestions');
        debugPrint(
            '👀 [AUTOCOMPLETE WIDGET] Show suggestions: $_showSuggestions');
      });
    } catch (e) {
      debugPrint('💥 [AUTOCOMPLETE WIDGET] Error in search: $e');

      if (mounted && !_isDisposed) {
        setState(() {
          _predictions = widget.showCurrentLocation &&
                  widget.currentLocationAddress != null
              ? [
                  {
                    'place_id': 'current_location',
                    'description': widget.currentLocationAddress!,
                    'is_current_location': true,
                  }
                ]
              : [];
          _isLoading = false;

          debugPrint(
              '🔄 [AUTOCOMPLETE WIDGET] Fallback to showing ${_predictions.length} suggestions');
        });
      }
    }
  }

  void _selectPlace(
      String placeId, String description, bool isCurrentLocation) {
    debugPrint('🎯 [AUTOCOMPLETE WIDGET] Place selected:');
    debugPrint('   📍 Place ID: $placeId');
    debugPrint('   📖 Description: $description');
    debugPrint('   🏠 Is Current Location: $isCurrentLocation');

    if (_isDisposed) {
      debugPrint(
          '⚠️ [AUTOCOMPLETE WIDGET] Widget disposed, cannot select place');
      return;
    }

    setState(() {
      _showSuggestions = false;
      _predictions = [];
    });

    widget.controller.text = description;
    widget.onPlaceSelected(placeId, description,
        isCurrentLocation: isCurrentLocation);

    // Unfocus after selection
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_isDisposed) {
        _focusNode.unfocus();
      }
    });

    debugPrint('✅ [AUTOCOMPLETE WIDGET] Place selection completed');
  }

  Widget _buildSuggestionsList() {
    if (!_showSuggestions || _isDisposed) {
      debugPrint(
          '🙈 [AUTOCOMPLETE UI] Not showing suggestions - show: $_showSuggestions, disposed: $_isDisposed');
      return const SizedBox.shrink();
    }

    if (_predictions.isEmpty) {
      debugPrint('📭 [AUTOCOMPLETE UI] No predictions to show');
      return Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            'No results found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    debugPrint(
        '📋 [AUTOCOMPLETE UI] Building list with ${_predictions.length} items');

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.maxSuggestionsHeight!,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Prevent focus loss when scrolling
            return true;
          },
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _predictions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[200]!,
            ),
            itemBuilder: (context, index) {
              final prediction = _predictions[index];
              final bool isCurrentLocation =
                  prediction['is_current_location'] == true;

              return InkWell(
                onTap: () => _selectPlace(
                  prediction['place_id'],
                  prediction['description'],
                  isCurrentLocation,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isCurrentLocation
                            ? Icons.my_location
                            : Icons.location_on,
                        color: isCurrentLocation ? Colors.blue : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          prediction['description'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentLocation
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentLocation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoading || _isDisposed) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Searching locations...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    debugPrint('🎨 [AUTOCOMPLETE WIDGET] Building widget');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          style: widget.textStyle ??
              const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
          onChanged: (value) {
            // Search is now handled by the debounced listener
          },
          onTap: () {
            debugPrint('👆 [AUTOCOMPLETE WIDGET] Text field tapped');
            _handleFocus();
          },
          decoration: widget.decoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                prefixIcon: widget.prefixIcon,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _isLoading
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : widget.controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              widget.controller.clear();
                              setState(() {
                                _predictions = [];
                                _showSuggestions = false;
                              });
                            },
                          )
                        : null,
              ),
        ),
        const SizedBox(height: 8),
        if (_isLoading || _showSuggestions) ...[
          if (_isLoading) _buildLoadingIndicator() else _buildSuggestionsList(),
        ],
      ],
    );
  }
}

// ============================
// MAIN SEARCH LOCATION SCREEN
// ============================
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

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [SEARCH LOCATION SCREEN] Initializing...');
    _getCurrentLocation();
  }

  @override
  void dispose() {
    debugPrint('🗑️ [SEARCH LOCATION SCREEN] Disposing...');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    debugPrint('📍 [LOCATION] Getting current location...');

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ [LOCATION] Location services are disabled');
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
      debugPrint('🔐 [LOCATION] Permission status: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📝 [LOCATION] Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ [LOCATION] Location permission denied by user');
          setState(() {
            _selectedAddress = "Location permissions denied";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ [LOCATION] Location permission permanently denied');
        setState(() {
          _selectedAddress = "Location permissions permanently denied";
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      debugPrint('📡 [LOCATION] Fetching current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      debugPrint('✅ [LOCATION] Position obtained:');
      debugPrint('   Latitude: ${position.latitude}');
      debugPrint('   Longitude: ${position.longitude}');

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

        debugPrint('📍 [LOCATION] Added current location marker');
      });

      // Move camera to current location when map is ready
      _moveToCurrentLocation();
    } catch (e) {
      debugPrint("💥 [LOCATION] Location access failed: $e");
      debugPrint("📝 [LOCATION] Stack trace: ${StackTrace.current}");

      setState(() {
        _selectedAddress = "Unable to get your location: ${e.toString()}";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentUserLocation != null) {
      debugPrint('🗺️ [MAP] Moving to current location...');
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentUserLocation!, zoom: 15.0),
          ),
        );
        debugPrint('✅ [MAP] Camera moved to current location');
      } catch (e) {
        debugPrint('❌ [MAP] Error moving camera: $e');
      }
    } else {
      debugPrint('⚠️ [MAP] No current location available to move to');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    debugPrint('🏠 [GEOCODING] Getting address for coordinates...');

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      debugPrint('📊 [GEOCODING] Received ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        debugPrint('🏠 [GEOCODING] Placemark details:');
        debugPrint('   Street: ${place.street}');
        debugPrint('   SubLocality: ${place.subLocality}');
        debugPrint('   Locality: ${place.locality}');
        debugPrint('   Country: ${place.country}');
        debugPrint('   Name: ${place.name}'); // This might contain plus codes

        String fullAddress =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
                .replaceAll(", ,", ", ")
                .replaceAll(RegExp(r', $'), '');

        // Remove Plus Code (Open Location Code) if present - typically looks like "XXXX+XX" format
        fullAddress = _removePlusCodeFromAddress(fullAddress);

        debugPrint('📫 [GEOCODING] Formatted address: $fullAddress');

        setState(() {
          _selectedAddress = fullAddress.isNotEmpty
              ? fullAddress
              : "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        });
      } else {
        debugPrint('📭 [GEOCODING] No placemarks found');
        setState(() {
          _selectedAddress =
              "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        });
      }
    } catch (e) {
      debugPrint('💥 [GEOCODING] Error getting address: $e');
      setState(() {
        _selectedAddress =
            "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
      });
    }
  }

  /// Removes Plus Codes (Open Location Codes) from the address string
  /// Plus codes typically have the format of 4-8 alphanumeric characters followed by a plus sign and 2-4 more characters
  /// Example: "QCJ3+FHV Shohid Mamun Hall Sarkari Titumir College, Dhaka, Bangladesh"
  /// becomes: "Shohid Mamun Hall Sarkari Titumir College, Dhaka, Bangladesh"
  String _removePlusCodeFromAddress(String address) {
    // Regular expression to match Plus Code patterns (e.g., "XXXX+XX", "XXX+XXX")
    // This pattern looks for groups of 2-8 alphanumeric characters followed by a '+' and 2-4 more alphanumeric characters
    RegExp plusCodeRegex = RegExp(
      r'\b[A-Z0-9]{2,8}\+[A-Z0-9]{2,8}\b\s*',
      caseSensitive: false,
    );

    String cleanedAddress = address.replaceAll(plusCodeRegex, '');

    // Clean up any extra spaces or commas that might result from the removal
    cleanedAddress = cleanedAddress.replaceAll(RegExp(r',\s*,\s*'), ', ');
    cleanedAddress = cleanedAddress.replaceAll(RegExp(r'^,\s*'), '');
    cleanedAddress = cleanedAddress.replaceAll(RegExp(r',\s*$'), '');

    return cleanedAddress.trim();
  }

  void _showLocationServicesDialog() {
    debugPrint('💬 [DIALOG] Showing location services dialog');

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
              debugPrint('⚙️ [DIALOG] Opening location settings');
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
    debugPrint('🗺️ [MAP] Map tapped at:');
    debugPrint('   Latitude: ${position.latitude}');
    debugPrint('   Longitude: ${position.longitude}');

    // Clear existing markers
    setState(() {
      _markers.clear();
      debugPrint('🗑️ [MAP] Cleared existing markers');
    });

    // Get address for the selected location
    String addressText =
        "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";

    try {
      debugPrint('🏠 [MAP] Getting address for tapped location...');
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

        // Remove Plus Code (Open Location Code) if present - typically looks like "XXXX+XX" format
        fullAddress = _removePlusCodeFromAddress(fullAddress);

        addressText = fullAddress.isNotEmpty ? fullAddress : addressText;
        debugPrint('📫 [MAP] Address found: $addressText');
      } else {
        debugPrint('📭 [MAP] No address found for tapped location');
      }
    } catch (e) {
      debugPrint('💥 [MAP] Geocoding error: $e');
    }

    // Update the address display
    setState(() {
      _selectedAddress = addressText;
      debugPrint('📝 [MAP] Updated selected address: $_selectedAddress');
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

      debugPrint('📍 [MAP] Added selected location marker');
      debugPrint('🎯 [MAP] Selected location stored for booking');
    });
  }

  void _goToCurrentLocation() async {
    debugPrint('📍 [BUTTON] Go to current location pressed');

    if (_currentUserLocation != null) {
      debugPrint('🗺️ [BUTTON] Moving to current location...');

      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentUserLocation!, zoom: 15.0),
          ),
        );

        debugPrint('✅ [BUTTON] Moved to current location');

        // Show a message that they need to tap to select
        Get.snackbar(
          'Tap to Select',
          'Long press on the map to select this location',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('❌ [BUTTON] Error moving to location: $e');
      }
    } else {
      debugPrint('🔄 [BUTTON] Getting current location first...');
      await _getCurrentLocation();
    }
  }

  // New function to handle place selection from search
  Future<void> _onPlaceSelected(String placeId, String description,
      {bool isCurrentLocation = false}) async {
    debugPrint('🎯 [SEARCH] Place selected from search:');
    debugPrint('   Place ID: $placeId');
    debugPrint('   Description: $description');
    debugPrint('   Is Current Location: $isCurrentLocation');

    if (isCurrentLocation && _currentUserLocation != null) {
      debugPrint('📍 [SEARCH] Current location selected');

      // Move to current location
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentUserLocation!, zoom: 15.0),
          ),
        );

        debugPrint('✅ [SEARCH] Moved to current location');

        // Select current location
        _onMapTapped(_currentUserLocation!);
      } catch (e) {
        debugPrint('❌ [SEARCH] Error moving to current location: $e');
      }
    } else {
      debugPrint('🔍 [SEARCH] Fetching place details...');

      // Fetch place details and move to that location
      final locationRepo = LocationRepository();
      final LatLng? location = await locationRepo.fetchPlaceDetails(placeId);

      if (location != null && mounted) {
        debugPrint('✅ [SEARCH] Place details fetched successfully');

        try {
          final GoogleMapController controller = await _controller.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: location, zoom: 15.0),
            ),
          );

          debugPrint('✅ [SEARCH] Moved to searched location');

          // Select the searched location
          _onMapTapped(location);

          // Update address - remove Plus Code if it's present in the description
          String cleanedDescription = _removePlusCodeFromAddress(description);
          setState(() {
            _selectedAddress = cleanedDescription;
            debugPrint('📝 [SEARCH] Updated address to: $cleanedDescription');
          });
        } catch (e) {
          debugPrint('❌ [SEARCH] Error moving camera: $e');
        }
      } else {
        debugPrint('❌ [SEARCH] Could not fetch place details');
      }
    }

    // Clear search
    _searchController.clear();
    debugPrint('🧹 [SEARCH] Cleared search controller');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [SCREEN] Building SearchLocationScreen');

    final arguments = Get.arguments as Map<String, dynamic>?;
    final bookingDateTime = arguments?['bookingDateTime'] ?? '';
    final providerID = arguments?['providerID'] ?? '';

    debugPrint('📋 [SCREEN] Arguments received:');
    debugPrint('   Booking DateTime: $bookingDateTime');
    debugPrint('   Provider ID: $providerID');

    // Determine initial camera position
    CameraPosition initialPosition;
    if (_currentUserLocation != null) {
      // Use current user location if available
      initialPosition = CameraPosition(
        target: _currentUserLocation!,
        zoom: 15.0,
      );
      debugPrint('🗺️ [SCREEN] Using current location for initial position');
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
        debugPrint(
            '🗺️ [SCREEN] Using arguments location for initial position');
      } else {
        initialPosition = _kBangladesh;
        debugPrint('🗺️ [SCREEN] Using default Bangladesh location');
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
            onPressed: () {
              debugPrint('🔍 [APPBAR] Search bar toggle pressed');
              setState(() {
                _showSearchBar = !_showSearchBar;
                debugPrint('   Search bar visible: $_showSearchBar');
              });
            },
            icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
            tooltip: "Toggle search bar",
          ),
          IconButton(
            onPressed: _goToCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: "Go to my current location",
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (Conditional)
          if (_showSearchBar)
            Container(
              padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
              color: Colors.white,
              child: PlaceAutocompleteWidget(
                controller: _searchController,
                hintText: "Search for a location...",
                onPlaceSelected: _onPlaceSelected,
                showCurrentLocation: true,
                currentLocationAddress: _selectedAddress,
                prefixIcon: const Icon(Icons.search),
                maxSuggestions: 5,
                maxSuggestionsHeight: 250,
                enabled: !_isLoadingLocation,
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
                    debugPrint('🗺️ [MAP] GoogleMap created');
                    _controller.complete(controller);
                    // If we already have current location, move camera to it
                    if (_currentUserLocation != null && !_hasInitialLocation) {
                      _hasInitialLocation = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _moveToCurrentLocation();
                      });
                    } else if (_currentUserLocation == null) {
                      // If no current location yet, ensure map shows default view
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        try {
                          await controller.animateCamera(
                            CameraUpdate.newCameraPosition(_kBangladesh),
                          );
                        } catch (e) {
                          debugPrint('❌ [MAP] Error in fallback camera: $e');
                        }
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
                  bottom: _selectedLocation != null ? 120.h : 20.h,
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
                          debugPrint('✅ [BUTTON] Confirm Location pressed');
                          debugPrint('📋 [BUTTON] Data to pass:');
                          debugPrint('   Provider ID: $providerID');
                          debugPrint('   Booking Date Time: $bookingDateTime');
                          debugPrint(
                              '   Latitude: ${_selectedLocation!.latitude}');
                          debugPrint(
                              '   Longitude: ${_selectedLocation!.longitude}');
                          debugPrint('   Address: $_selectedAddress');

                          // Navigate to service preview with selected location data
                          Get.toNamed(
                            Routes.servicePreviewScreen,
                            arguments: {
                              'providerID': providerID,
                              'bookingDateTime': bookingDateTime,
                              'lat': _selectedLocation!.latitude,
                              'long': _selectedLocation!.longitude,
                              'address': _selectedAddress,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.c5c5c5c,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Confirm Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Loading overlay - only show when truly loading and map is not ready
                if (_isLoadingLocation && _markers.isEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Getting your location...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
