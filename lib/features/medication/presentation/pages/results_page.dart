import 'package:flutter/material.dart';

import 'reservation_page.dart';

final class ResultsPage extends StatelessWidget {
  const ResultsPage({
    required this.medicine,
    required this.city,
    super.key,
  });

  final String medicine;
  final String city;

  @override
  Widget build(BuildContext context) {
    const offers = [
      _Offer(
        pharmacy: 'Farmácia Central',
        status: 'Em estoque',
        distance: '1,2 km',
        price: 'R\$ 18,90',
        detail: 'Retirada hoje',
        statusColor: Color(0xFF0A966A),
      ),
      _Offer(
        pharmacy: 'Drogaria São Lucas',
        status: 'Últimas unidades',
        distance: '2,4 km',
        price: 'R\$ 19,50',
        detail: 'Entrega disponível',
        statusColor: Color(0xFFE28A00),
      ),
      _Offer(
        pharmacy: 'Farmácia Popular Vida',
        status: 'Em estoque',
        distance: '3,1 km',
        price: 'R\$ 17,80',
        detail: 'Receita exigida',
        statusColor: Color(0xFF0A966A),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Resultados',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Card(
            elevation: 0,
            color: const Color(0xFFEAF8F3),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.medication_rounded, color: Color(0xFF0A966A)),
              ),
              title: Text(
                medicine,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(city),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '3 farmácias encontradas',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...offers.map(
            (offer) => _OfferCard(
              offer: offer,
              medicine: medicine,
              city: city,
            ),
          ),
        ],
      ),
    );
  }
}

final class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.medicine,
    required this.city,
  });

  final _Offer offer;
  final String medicine;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF8F3),
                  child: Icon(Icons.local_pharmacy_rounded, color: Color(0xFF0A966A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    offer.pharmacy,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                ),
                Text(offer.distance),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: offer.statusColor.withAlpha(24),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    offer.status,
                    style: TextStyle(
                      color: offer.statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  offer.price,
                  style: const TextStyle(
                    color: Color(0xFF0A966A),
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 19),
                const SizedBox(width: 7),
                Text(offer.detail),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Ver detalhes'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReservationPage(
                            pharmacy: offer.pharmacy,
                            medicine: medicine,
                            city: city,
                            price: offer.price,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      offer.detail.contains('Entrega')
                          ? 'Solicitar entrega'
                          : 'Reservar',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _Offer {
  const _Offer({
    required this.pharmacy,
    required this.status,
    required this.distance,
    required this.price,
    required this.detail,
    required this.statusColor,
  });

  final String pharmacy;
  final String status;
  final String distance;
  final String price;
  final String detail;
  final Color statusColor;
}
