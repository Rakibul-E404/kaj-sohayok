import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/routes/routes.dart';
import 'package:latlong2/latlong.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  // Initial center and marker position at Dhaka, Bangladesh
  LatLng _markerPosition = LatLng(23.8103, 90.4125);

  // Initial zoom level
  double _zoomLevel = 15.0;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          // Map with tap listener to update marker position
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                // center: _markerPosition,
                // zoom: _zoomLevel,
                onTap: (tapPosition, point) {
                  setState(() {
                    _markerPosition = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ["a", "b", "c"],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _markerPosition,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Overlay UI on top of map
          SafeArea(
            child: Column(
              children: [
                // Search box with styling
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        hintText: "Search Location",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Proceed button, full width
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.servicePreviewScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B73FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0x996B73FF),
                      ),
                      child: const Text(
                        "Proceed",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Add the zoom buttons at a fixed position
          Positioned(
            bottom: 100.0,
            right: 10.0,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "locateBtn",
                  onPressed: () {
                    /// Locate buttons
                    setState(() {
                      // if (_zoomLevel < 18.0) {
                      //   _zoomLevel++;
                      // }
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.location_searching),
                ),

                const SizedBox(height: 10),

                ///=============================== Zoom-in button
                FloatingActionButton(
                  heroTag: "zoomInBtn",
                  onPressed: () {
                    /// Zoom in action (increase zoom level)
                    setState(() {
                      if (_zoomLevel < 18.0) {
                        _zoomLevel++;
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),

                ///========================================= Zoom-out button
                FloatingActionButton(
                  heroTag: "zoomOutBtn",
                  onPressed: () {
                    /// Zoom out action (decrease zoom level)
                    setState(() {
                      if (_zoomLevel > 1.0) {
                        _zoomLevel--;
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
