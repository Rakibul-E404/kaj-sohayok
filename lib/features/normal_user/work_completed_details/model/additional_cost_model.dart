// class AdditionalCostModel {
//   final String title;
//   final double price;
//   AdditionalCostModel({required this.title, required this.price});
// }




class AdditionalCostModel {
  final String? id; // Nullable ID field
  final String title;
  final double price;
  final String? bookingId; // Add booking ID reference
  final DateTime? createdAt;

  AdditionalCostModel({
    this.id,
    required this.title,
    required this.price,
    this.bookingId,
    this.createdAt,
  });

  // Factory constructor from JSON
  factory AdditionalCostModel.fromJson(Map<String, dynamic> json) {
    return AdditionalCostModel(
      id: json['_AdditionalCostId'],
      title: json['costName']?.toString() ??
          json['title']?.toString() ??
          'Additional Cost',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      bookingId: json['serviceBookingId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && !id!.startsWith('temp_')) 'id': id,
      'title': title,
      'costName': title,
      'price': price.toString(),
      if (bookingId != null) 'serviceBookingId': bookingId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

}


