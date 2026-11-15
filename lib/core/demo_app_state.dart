import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class HistoryEntry {
  const HistoryEntry({
    required this.medicine,
    required this.pharmacy,
    required this.mode,
    required this.status,
    required this.dateLabel,
    required this.totalLabel,
    required this.orderNumber,
    this.quantity = 1,
    this.address,
    this.payment = 'Cartão de crédito',
  });

  final String medicine;
  final String pharmacy;
  final String mode;
  final String status;
  final String dateLabel;
  final String totalLabel;
  final String orderNumber;
  final int quantity;
  final String? address;
  final String payment;

  HistoryEntry copyWith({
    String? status,
  }) {
    return HistoryEntry(
      medicine: medicine,
      pharmacy: pharmacy,
      mode: mode,
      status: status ?? this.status,
      dateLabel: dateLabel,
      totalLabel: totalLabel,
      orderNumber: orderNumber,
      quantity: quantity,
      address: address,
      payment: payment,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicine': medicine,
        'pharmacy': pharmacy,
        'mode': mode,
        'status': status,
        'dateLabel': dateLabel,
        'totalLabel': totalLabel,
        'orderNumber': orderNumber,
        'quantity': quantity,
        'address': address,
        'payment': payment,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        medicine: json['medicine'] as String? ?? '',
        pharmacy: json['pharmacy'] as String? ?? '',
        mode: json['mode'] as String? ?? 'Retirada',
        status: json['status'] as String? ?? 'Concluída',
        dateLabel: json['dateLabel'] as String? ?? '',
        totalLabel: json['totalLabel'] as String? ?? 'R\$ 0,00',
        orderNumber: json['orderNumber'] as String? ?? 'FA-DEMO',
        quantity: json['quantity'] as int? ?? 1,
        address: json['address'] as String?,
        payment: json['payment'] as String? ?? 'Cartão de crédito',
      );
}

final class DemoAppState extends ChangeNotifier {
  DemoAppState._();

  static final DemoAppState instance = DemoAppState._();

  static const _favoritesPharmaciesKey = 'favorite_pharmacies';
  static const _favoritesMedicinesKey = 'favorite_medicines';
  static const _historyKey = 'history_entries';
  static const _addressKey = 'profile_address';
  static const _photoKey = 'profile_photo';
  static const _recentSearchesKey = 'recent_searches';

  final Set<String> _favoritePharmacies = <String>{};
  final Set<String> _favoriteMedicines = <String>{};
  final List<HistoryEntry> _history = <HistoryEntry>[];
  final List<String> _recentSearches = <String>[];

  String? _profileAddress;
  Uint8List? _profilePhotoBytes;
  bool _initialized = false;

  Set<String> get favoritePharmacies => Set.unmodifiable(_favoritePharmacies);
  Set<String> get favoriteMedicines => Set.unmodifiable(_favoriteMedicines);
  List<HistoryEntry> get history => List.unmodifiable(_history);
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  String? get profileAddress => _profileAddress;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    _favoritePharmacies
      ..clear()
      ..addAll(prefs.getStringList(_favoritesPharmaciesKey) ?? const []);

    _favoriteMedicines
      ..clear()
      ..addAll(prefs.getStringList(_favoritesMedicinesKey) ?? const []);

    _recentSearches
      ..clear()
      ..addAll(prefs.getStringList(_recentSearchesKey) ?? const []);

    _profileAddress = prefs.getString(_addressKey);

    final photo = prefs.getString(_photoKey);
    if (photo != null && photo.isNotEmpty) {
      try {
        _profilePhotoBytes = base64Decode(photo);
      } catch (_) {
        _profilePhotoBytes = null;
      }
    }

    final rawHistory = prefs.getString(_historyKey);
    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHistory) as List<dynamic>;
        _history
          ..clear()
          ..addAll(
            decoded.map(
              (item) => HistoryEntry.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
          );
      } catch (_) {
        _history.clear();
      }
    }

    if (_history.isEmpty) {
      _history.addAll(const [
        HistoryEntry(
          medicine: 'Losartana 50 mg',
          pharmacy: 'Farmácia Agreste',
          mode: 'Delivery',
          status: 'Entregue',
          dateLabel: 'Hoje, 14:20',
          totalLabel: 'R\$ 25,80',
          orderNumber: 'FA-20261115-1420',
          address: 'Endereço demonstrativo',
          payment: 'Pix',
        ),
        HistoryEntry(
          medicine: 'Dipirona 500 mg',
          pharmacy: 'Drogaria Bom Sucesso',
          mode: 'Retirada',
          status: 'Concluída',
          dateLabel: '12/11/2026, 10:05',
          totalLabel: 'R\$ 8,90',
          orderNumber: 'FA-20261112-1005',
        ),
      ]);
      await _saveHistory();
    }

    _initialized = true;
    notifyListeners();
  }

  bool isFavorite(String pharmacy) => _favoritePharmacies.contains(pharmacy);
  bool isMedicineFavorite(String medicine) =>
      _favoriteMedicines.contains(medicine);

  Future<void> toggleFavorite(String pharmacy) async {
    if (!_favoritePharmacies.add(pharmacy)) {
      _favoritePharmacies.remove(pharmacy);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesPharmaciesKey,
      _favoritePharmacies.toList(),
    );
    notifyListeners();
  }

  Future<void> toggleMedicineFavorite(String medicine) async {
    if (!_favoriteMedicines.add(medicine)) {
      _favoriteMedicines.remove(medicine);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesMedicinesKey,
      _favoriteMedicines.toList(),
    );
    notifyListeners();
  }

  Future<void> addRecentSearch(String medicine) async {
    final normalized = medicine.trim();
    if (normalized.isEmpty) return;

    _recentSearches.removeWhere(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);
    if (_recentSearches.length > 6) {
      _recentSearches.removeRange(6, _recentSearches.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    notifyListeners();
  }

  Future<void> setProfileAddress(String? address) async {
    _profileAddress = address?.trim().isEmpty == true ? null : address?.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_profileAddress == null) {
      await prefs.remove(_addressKey);
    } else {
      await prefs.setString(_addressKey, _profileAddress!);
    }
    notifyListeners();
  }

  Future<void> setProfilePhoto(Uint8List bytes) async {
    _profilePhotoBytes = bytes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, base64Encode(bytes));
    notifyListeners();
  }

  Future<void> addHistory(HistoryEntry entry) async {
    _history.insert(0, entry);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderNumber, String status) async {
    final index = _history.indexWhere(
      (item) => item.orderNumber == orderNumber,
    );
    if (index < 0) return;

    _history[index] = _history[index].copyWith(status: status);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(_history.map((item) => item.toJson()).toList()),
    );
  }
}
