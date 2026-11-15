import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';
import 'authorize_pickup_page.dart';
import 'order_details_page.dart';

final class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return AnimatedBuilder(
      animation: DemoAppState.instance,
      builder: (context, _) {
        final items = DemoAppState.instance.activePurchases;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text(
              'Compras e reservas',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10243B),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Acompanhe tudo que ainda está em andamento.'),
            const SizedBox(height: 18),
            if (items.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.pending_actions_rounded, size: 18),
                  label: Text(
                    items.length.toString() + ' pendência(s)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: green,
                        size: 42,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nenhuma compra ou reserva pendente.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFEAF8F3),
                              child: Icon(
                                item.mode == 'Delivery'
                                    ? Icons.local_shipping_outlined
                                    : Icons.medication_rounded,
                                color: green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.medicine,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(item.orderNumber),
                                ],
                              ),
                            ),
                            _StatusBadge(status: item.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (item.mode == 'Retirada') ...[
                          Row(
                            children: [
                              const Icon(Icons.local_pharmacy_outlined, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.pharmacy,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.authorizedPickupName == null
                                ? 'Retirada pelo titular da conta.'
                                : 'Retirada autorizada para ' +
                                    item.authorizedPickupName! + '.',
                          ),
                        ] else ...[
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.address ?? 'Endereço cadastrado',
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailsPage(
                                        orderNumber: item.orderNumber,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Detalhes'),
                              ),
                            ),
                            if (item.mode == 'Retirada') ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AuthorizePickupPage(
                                          orderNumber: item.orderNumber,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.person_add_alt_1_rounded),
                                  label: Text(
                                    item.authorizedPickupName == null
                                        ? 'Autorizar'
                                        : 'Alterar',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

final class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F3),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0A966A),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
