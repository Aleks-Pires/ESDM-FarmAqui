import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';
import '../../data/models/medication_offer.dart';

final class MedicationDetailsPage extends StatelessWidget {
  const MedicationDetailsPage({
    required this.medicine,
    required this.offers,
    super.key,
  });

  final String medicine;
  final List<MedicationOffer> offers;

  @override
  Widget build(BuildContext context) {
    final requiresPrescription =
        offers.any((offer) => offer.prescriptionRequired);
    final deliveryCount = offers.where((offer) => offer.delivery).length;
    final prices = offers.map((offer) => offer.price).toList()..sort();
    final lowest = prices.isEmpty ? 0.0 : prices.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do medicamento',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            color: const Color(0xFFEAF8F3),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.medication_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      medicine,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: DemoAppState.instance,
                    builder: (context, _) => IconButton(
                      tooltip: 'Favoritar medicamento',
                      onPressed: () => DemoAppState.instance
                          .toggleMedicineFavorite(medicine),
                      icon: Icon(
                        DemoAppState.instance.isMedicineFavorite(medicine)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: DemoAppState.instance
                                .isMedicineFavorite(medicine)
                            ? Colors.redAccent
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _InfoTile(
            icon: Icons.local_pharmacy_outlined,
            title: 'Farmácias encontradas',
            value: offers.length.toString(),
          ),
          _InfoTile(
            icon: Icons.local_shipping_outlined,
            title: 'Com delivery',
            value: deliveryCount.toString(),
          ),
          _InfoTile(
            icon: Icons.payments_outlined,
            title: 'Menor preço encontrado',
            value: 'R\$ ' + lowest.toStringAsFixed(2).replaceAll('.', ','),
          ),
          _InfoTile(
            icon: Icons.receipt_long_outlined,
            title: 'Receita',
            value: requiresPrescription
                ? 'Exigida nesta apresentação'
                : 'Não indicada como obrigatória',
          ),
          const SizedBox(height: 18),
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Informações demonstrativas. Em uma versão de produção, '
                'bula, princípio ativo, fabricante e regras de dispensação '
                'seriam obtidos de uma fonte farmacêutica oficial.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0A966A)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
