import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/medication_offer.dart';

final class MedicationService {
  MedicationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  Future<MedicationSearchResult> search({
    required String medicine,
    required String city,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/medicamentos').replace(
        queryParameters: {
          'nome': medicine,
          'cidade': city,
        },
      );

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return _fromApi(json, medicine: medicine, city: city);
      }
    } catch (_) {
      // Fallback local logo abaixo.
    }

    return _fromLocalAsset(medicine: medicine, city: city);
  }

  Future<bool> createReservation({
    required String pharmacy,
    required String medicine,
    required int quantity,
    required bool delivery,
    required String payment,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/reservas'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'pharmacy': pharmacy,
              'medicine': medicine,
              'quantity': quantity,
              'delivery': delivery,
              'payment': payment,
            }),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
    } catch (_) {
      // Em modo de demonstração, a reserva pode seguir localmente.
    }

    return true;
  }

  MedicationSearchResult _fromApi(
    Map<String, dynamic> json, {
    required String medicine,
    required String city,
  }) {
    final rawOffers = json['offers'] as List<dynamic>? ?? const [];

    return MedicationSearchResult(
      medicine: json['medicine'] as String? ?? medicine,
      city: json['city'] as String? ?? city,
      offers: rawOffers
          .map(
            (item) => MedicationOffer.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      source: json['source'] as String? ?? 'mock-api',
    );
  }

  Future<MedicationSearchResult> _fromLocalAsset({
    required String medicine,
    required String city,
  }) async {
    final raw = await rootBundle.loadString('assets/mock/medications.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final medications = json['medications'] as List<dynamic>? ?? const [];
    final query = medicine.trim().toLowerCase();

    final offers = <MedicationOffer>[];

    for (final item in medications) {
      final map = item as Map<String, dynamic>;
      final itemName = (map['name'] as String? ?? '').toLowerCase();

      if (query.contains(itemName) || itemName.contains(query)) {
        final rawOffers = map['offers'] as List<dynamic>? ?? const [];
        offers.addAll(
          rawOffers.map(
            (offer) => MedicationOffer.fromJson(
              offer as Map<String, dynamic>,
            ),
          ),
        );
      }
    }

    return MedicationSearchResult(
      medicine: medicine,
      city: city,
      offers: offers,
      source: 'json-local',
    );
  }
}
