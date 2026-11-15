import 'package:flutter/foundation.dart';

final class HistoryEntry {
  const HistoryEntry({
    required this.medicine,
    required this.pharmacy,
    required this.mode,
    required this.status,
    required this.dateLabel,
    required this.totalLabel,
    required this.orderNumber,
  });

  final String medicine;
  final String pharmacy;
  final String mode;
  final String status;
  final String dateLabel;
  final String totalLabel;
  final String orderNumber;
}

final class DemoAppState extends ChangeNotifier {
  DemoAppState._();

  static final DemoAppState instance = DemoAppState._();

  final Set<String> _favoritePharmacies = <String>{};
  final List<HistoryEntry> _history = <HistoryEntry>[
    const HistoryEntry(
      medicine: 'Losartana 50 mg',
      pharmacy: 'Farmácia Agreste',
      mode: 'Delivery',
      status: 'Entregue',
      dateLabel: 'Hoje, 14:20',
      totalLabel: 'R$ 25,80',
      orderNumber: 'FA-20261115-1420',
    ),
    const HistoryEntry(
      medicine: 'Dipirona 500 mg',
      pharmacy: 'Drogaria Bom Sucesso',
      mode: 'Retirada',
      status: 'Concluída',
      dateLabel: '12/11/2026, 10:05',
      totalLabel: 'R$ 8,90',
      orderNumber: 'FA-20261112-1005',
    ),
  ];

  Set<String> get favoritePharmacies => Set.unmodifiable(_favoritePharmacies);
  List<HistoryEntry> get history => List.unmodifiable(_history);

  bool isFavorite(String pharmacy) => _favoritePharmacies.contains(pharmacy);

  void toggleFavorite(String pharmacy) {
    if (!_favoritePharmacies.add(pharmacy)) {
      _favoritePharmacies.remove(pharmacy);
    }
    notifyListeners();
  }

  void addHistory(HistoryEntry entry) {
    _history.insert(0, entry);
    notifyListeners();
  }
}
