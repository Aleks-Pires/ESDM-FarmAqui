final class MedicationOffer {
  const MedicationOffer({
    required this.pharmacy,
    required this.distance,
    required this.price,
    required this.status,
    required this.detail,
    required this.pickup,
    required this.delivery,
    required this.prescriptionRequired,
  });

  final String pharmacy;
  final String distance;
  final double price;
  final String status;
  final String detail;
  final bool pickup;
  final bool delivery;
  final bool prescriptionRequired;

  factory MedicationOffer.fromJson(Map<String, dynamic> json) {
    return MedicationOffer(
      pharmacy: json['pharmacy'] as String? ?? 'Farmácia',
      distance: json['distance'] as String? ?? '-',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'Indisponível',
      detail: json['detail'] as String? ?? '',
      pickup: json['pickup'] as bool? ?? false,
      delivery: json['delivery'] as bool? ?? false,
      prescriptionRequired: json['prescriptionRequired'] as bool? ?? false,
    );
  }
}

final class MedicationSearchResult {
  const MedicationSearchResult({
    required this.medicine,
    required this.city,
    required this.offers,
    required this.source,
  });

  final String medicine;
  final String city;
  final List<MedicationOffer> offers;
  final String source;
}
