import 'package:flutter_test/flutter_test.dart';

import 'package:farma_aqui/core/medication_catalog.dart';
import 'package:farma_aqui/features/medication/data/models/medication_offer.dart';

void main() {
  group('Catálogo de medicamentos', () {
    test('sugere dosagens separadas ao buscar por nome parcial', () {
      final results = medicationSuggestionsFor('los').toList();

      expect(results, contains('Losartana 25 mg'));
      expect(results, contains('Losartana 50 mg'));
      expect(results, contains('Losartana 100 mg'));
    });

    test('oferece apresentações alternativas quando a dose não existe', () {
      final alternatives = alternativePresentations('Losartana 75 mg');

      expect(alternatives, contains('Losartana 25 mg'));
      expect(alternatives, contains('Losartana 50 mg'));
      expect(alternatives, contains('Losartana 100 mg'));
    });

    test('aceita sinônimo simples na busca', () {
      final results = medicationSuggestionsFor('metamizol').toList();

      expect(results, contains('Dipirona 500 mg'));
      expect(results, contains('Dipirona 1 g'));
    });
  });

  test('MedicationOffer interpreta uma oferta do JSON', () {
    final offer = MedicationOffer.fromJson({
      'pharmacy': 'Farmácia Teste',
      'distance': '1,0 km',
      'price': 12.5,
      'status': 'Em estoque',
      'detail': 'Delivery disponível',
      'pickup': true,
      'delivery': true,
      'prescriptionRequired': false,
    });

    expect(offer.pharmacy, 'Farmácia Teste');
    expect(offer.price, 12.5);
    expect(offer.delivery, isTrue);
    expect(offer.prescriptionRequired, isFalse);
  });
}
