class Address {
  final String? street;
  final String? subLocality;
  final String? locality; // City
  final String? postalCode;
  final String? country;

  Address({
    this.street,
    this.subLocality,
    this.locality,
    this.postalCode,
    this.country,
  });

  @override
  String toString() {
    return '$street, $subLocality, $locality, $postalCode, $country';
  }
}