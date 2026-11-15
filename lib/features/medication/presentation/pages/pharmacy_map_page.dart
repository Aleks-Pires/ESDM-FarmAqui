import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/medication_offer.dart';
import 'reservation_page.dart';

final class PharmacyMapPage extends StatefulWidget {
  const PharmacyMapPage({
    required this.medicine,
    required this.city,
    required this.offers,
    super.key,
  });

  final String medicine;
  final String city;
  final List<MedicationOffer> offers;

  @override
  State<PharmacyMapPage> createState() => _PharmacyMapPageState();
}

final class _PharmacyMapPageState extends State<PharmacyMapPage> {
  static const _ufalArapiraca = LatLng(-9.7012582, -36.6873613);

  final MapController mapController = MapController();

  LatLng center = _ufalArapiraca;
  MedicationOffer? selectedOffer;

  List<LatLng> get pharmacyPoints {
    const offsets = [
      (0.0065, 0.0040),
      (-0.0050, 0.0070),
      (0.0030, -0.0075),
      (-0.0070, -0.0040),
      (0.0080, -0.0025),
      (-0.0020, 0.0090),
    ];

    return List.generate(widget.offers.length, (index) {
      final offset = offsets[index % offsets.length];
      return LatLng(
        center.latitude + offset.$1,
        center.longitude + offset.$2,
      );
    });
  }

  void _select(MedicationOffer offer, LatLng point) {
    setState(() => selectedOffer = offer);
    mapController.move(point, 15.5);
  }

  void _reserve(MedicationOffer offer) {
    final price =
        'R\$ ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationPage(
          pharmacy: offer.pharmacy,
          medicine: widget.medicine,
          city: widget.city,
          price: price,
          deliveryAvailable: offer.delivery,
          prescriptionRequired: offer.prescriptionRequired,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    final points = pharmacyPoints;

    final markers = <Marker>[
      Marker(
        point: center,
        width: 54,
        height: 54,
        child: const Tooltip(
          message: 'UFAL - Campus Arapiraca',
          child: Icon(
            Icons.school_rounded,
            size: 46,
            color: Color(0xFF1565C0),
          ),
        ),
      ),
      ...List.generate(widget.offers.length, (index) {
        final offer = widget.offers[index];
        final point = points[index];

        return Marker(
          point: point,
          width: 58,
          height: 58,
          child: GestureDetector(
            onTap: () => _select(offer, point),
            child: Tooltip(
              message: offer.pharmacy,
              child: const Icon(
                Icons.location_on_rounded,
                size: 48,
                color: green,
              ),
            ),
          ),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farmácias no mapa',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Centralizar na UFAL',
            onPressed: () => mapController.move(center, 14.5),
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.farmaaqui.app',
              ),
              MarkerLayer(markers: markers),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.offers.length} farmácia(s) simulada(s) em Arapiraca, '
                        'com referência no Campus UFAL Arapiraca.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedOffer != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 18,
              child: _SelectedPharmacyCard(
                offer: selectedOffer!,
                onReserve: () => _reserve(selectedOffer!),
              ),
            ),
        ],
      ),
    );
  }
}

final class _SelectedPharmacyCard extends StatelessWidget {
  const _SelectedPharmacyCard({
    required this.offer,
    required this.onReserve,
  });

  final MedicationOffer offer;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final price =
        'R\$ ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF8F3),
                  child: Icon(
                    Icons.local_pharmacy_rounded,
                    color: Color(0xFF0A966A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    offer.pharmacy,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  offer.distance,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(offer.status)),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF0A966A),
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(offer.detail),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: onReserve,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Ver reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
