// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/custom_widgets/custom_shimmer_effect.dart';
// import 'package:kaz_bd/features/demo_map_for_search_functionality/location_repository.dart';

// class PlaceAutocompleteWidget extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final Function(String placeId, String description, {bool isCurrentLocation})
//       onPlaceSelected;
//   final bool showCurrentLocation;
//   final String? currentLocationAddress;
//   final Widget? prefixIcon;
//   final InputDecoration? decoration;
//   final TextStyle? textStyle;
//   final TextStyle? hintStyle;
//   final EdgeInsetsGeometry? contentPadding;
//   final double? maxSuggestionsHeight;
//   final int? maxSuggestions;
//   final bool enabled;
//   final FocusNode? focusNode;

//   const PlaceAutocompleteWidget({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     required this.onPlaceSelected,
//     this.showCurrentLocation = false,
//     this.currentLocationAddress,
//     this.prefixIcon,
//     this.decoration,
//     this.textStyle,
//     this.hintStyle,
//     this.contentPadding,
//     this.maxSuggestionsHeight = 200,
//     this.maxSuggestions,
//     this.enabled = true,
//     this.focusNode,
//   }) : super(key: key);

//   @override
//   State<PlaceAutocompleteWidget> createState() =>
//       _PlaceAutocompleteWidgetState();
// }

// class _PlaceAutocompleteWidgetState extends State<PlaceAutocompleteWidget> {
//   final LocationRepository _locationRepository = LocationRepository();
//   late FocusNode _focusNode;

//   List<dynamic> _predictions = [];
//   bool _isLoading = false;
//   bool _showSuggestions = false;
//   bool _isDisposed = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();

//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus && mounted && !_isDisposed) {
//         _handleFocus();
//       } else if (!_focusNode.hasFocus && mounted && !_isDisposed) {
//         _handleUnfocus();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _handleFocus() {
//     if (widget.showCurrentLocation && widget.currentLocationAddress != null) {
//       setState(() {
//         _showSuggestions = true;
//         _predictions = [
//           {
//             'place_id': 'current_location',
//             'description': widget.currentLocationAddress!,
//             'is_current_location': true,
//           }
//         ];
//       });
//     }
//   }

//   void _handleUnfocus() {
//     // Delay hiding suggestions to allow for tap events
//     Future.delayed(const Duration(milliseconds: 150), () {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _showSuggestions = false;
//           _predictions = [];
//         });
//       }
//     });
//   }

//   Future<void> _searchPlaces(String query) async {
//     if (_isDisposed || !mounted) return;

//     if (query.isEmpty) {
//       setState(() {
//         _predictions =
//             widget.showCurrentLocation && widget.currentLocationAddress != null
//                 ? [
//                     {
//                       'place_id': 'current_location',
//                       'description': widget.currentLocationAddress!,
//                       'is_current_location': true,
//                     }
//                   ]
//                 : [];
//         _isLoading = false;
//         _showSuggestions = _predictions.isNotEmpty;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _showSuggestions = true;
//     });

//     try {
//       final predictions = await _locationRepository.placeAutoComplete(query);

//       if (_isDisposed || !mounted) return;

//       setState(() {
//         List<dynamic> finalPredictions = [];

//         // Add current location option if enabled
//         if (widget.showCurrentLocation &&
//             widget.currentLocationAddress != null) {
//           finalPredictions.add({
//             'place_id': 'current_location',
//             'description': widget.currentLocationAddress!,
//             'is_current_location': true,
//           });
//         }

//         // Add search predictions
//         finalPredictions.addAll(predictions);

//         // Limit suggestions if specified
//         if (widget.maxSuggestions != null &&
//             finalPredictions.length > widget.maxSuggestions!) {
//           finalPredictions =
//               finalPredictions.take(widget.maxSuggestions!).toList();
//         }

//         _predictions = finalPredictions;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _predictions = widget.showCurrentLocation &&
//                   widget.currentLocationAddress != null
//               ? [
//                   {
//                     'place_id': 'current_location',
//                     'description': widget.currentLocationAddress!,
//                     'is_current_location': true,
//                   }
//                 ]
//               : [];
//           _isLoading = false;
//         });
//       }
//       debugPrint('Place search error: $e');
//     }
//   }

//   void _selectPlace(
//       String placeId, String description, bool isCurrentLocation) {
//     if (_isDisposed) return;

//     setState(() {
//       _showSuggestions = false;
//       _predictions = [];
//     });

//     widget.controller.text = description;
//     widget.onPlaceSelected(placeId, description,
//         isCurrentLocation: isCurrentLocation);
//     _focusNode.unfocus();
//   }

//   Widget _buildSuggestionsList() {
//     if (!_showSuggestions || _predictions.isEmpty || _isDisposed) {
//       return const SizedBox.shrink();
//     }

//     return Material(
//       elevation: 4.0,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         constraints: BoxConstraints(
//           maxHeight: widget.maxSuggestionsHeight!,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.red),
//         ),
//         child: ListView.separated(
//           shrinkWrap: true,
//           padding: EdgeInsets.zero,
//           itemCount: _predictions.length,
//           separatorBuilder: (context, index) => const Divider(
//             height: 1,
//             thickness: 1,
//             color: Colors.amber,
//           ),
//           itemBuilder: (context, index) {
//             final prediction = _predictions[index];
//             final bool isCurrentLocation =
//                 prediction['is_current_location'] == true;

//             return InkWell(
//               onTap: () => _selectPlace(
//                 prediction['place_id'],
//                 prediction['description'],
//                 isCurrentLocation,
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isCurrentLocation ? Icons.my_location : Icons.location_on,
//                       color:
//                           isCurrentLocation ? Colors.black : Colors.greenAccent,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         prediction['description'],
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: isCurrentLocation
//                               ? FontWeight.w600
//                               : FontWeight.normal,
//                           color: Colors.black,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (isCurrentLocation)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text(
//                           'Current',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     if (!_isLoading || _isDisposed) {
//       return const SizedBox.shrink();
//     }

//     return Material(
//       elevation: 4.0,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.green),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomShimmerEffect(height: 40.h, width: 40.w),
//             const SizedBox(width: 12),
//             const Text(
//               'Searching...',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isDisposed) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: widget.controller,
//           focusNode: _focusNode,
//           enabled: widget.enabled,
//           style: widget.textStyle ??
//               const TextStyle(
//                 color: Colors.amberAccent,
//                 fontSize: 16,
//               ),
//           onChanged: _searchPlaces,
//           onTap: _handleFocus,
//           decoration: widget.decoration ??
//               InputDecoration(
//                 hintText: widget.hintText,
//                 hintStyle: widget.hintStyle ??
//                     const TextStyle(
//                       color: Colors.blue,
//                       fontSize: 16,
//                     ),
//                 prefixIcon: widget.prefixIcon,
//                 contentPadding: widget.contentPadding ??
//                     const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.black, width: 2),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//         ),
//         if (_isLoading || _showSuggestions) ...[
//           const SizedBox(height: 8),
//           if (_isLoading) _buildLoadingIndicator() else _buildSuggestionsList(),
//         ],
//       ],
//     );
//   }
// }
