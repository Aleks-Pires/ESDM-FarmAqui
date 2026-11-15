import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';

final class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return AnimatedBuilder(
      animation: DemoAppState.instance,
      builder: (context, _) {
        final items = DemoAppState.instance.history;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text(
              'Histórico',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10243B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Acompanhe suas reservas, retiradas e pedidos anteriores.',
            ),
            const SizedBox(height: 22),
            if (items.isEmpty)
              const Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text(
                    'Você ainda não possui pedidos ou reservas concluídos.',
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                    : Icons.shopping_bag_outlined,
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
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(item.pharmacy),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF8F3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.status,
                                style: const TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido ' + item.orderNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.mode + ' • ' + item.dateLabel),
                            ),
                            Text(
                              item.totalLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: green,
                              ),
                            ),
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
