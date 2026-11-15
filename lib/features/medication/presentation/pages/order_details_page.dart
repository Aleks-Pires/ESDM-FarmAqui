import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';
import 'results_page.dart';

final class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.orderNumber,
    super.key,
  });

  final String orderNumber;

  HistoryEntry? _currentEntry() {
    for (final item in DemoAppState.instance.history) {
      if (item.orderNumber == orderNumber) return item;
    }
    return null;
  }

  List<String> _steps(HistoryEntry entry) {
    if (entry.mode == 'Delivery') {
      return const [
        'Pedido confirmado',
        'Preparando',
        'Saiu para entrega',
        'Entregue',
      ];
    }

    return const [
      'Reserva confirmada',
      'Pronto para retirada',
      'Concluída',
    ];
  }

  Future<void> _advance(HistoryEntry entry) async {
    final steps = _steps(entry);
    final index = steps.indexOf(entry.status);

    if (index >= 0 && index < steps.length - 1) {
      await DemoAppState.instance.updateOrderStatus(
        entry.orderNumber,
        steps[index + 1],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DemoAppState.instance,
      builder: (context, _) {
        final entry = _currentEntry();

        if (entry == null) {
          return const Scaffold(
            body: Center(child: Text('Pedido não encontrado.')),
          );
        }

        final steps = _steps(entry);
        final currentIndex = steps.indexOf(entry.status);
        final isCancelled = entry.status == 'Cancelado';
        final isFinished = isCancelled ||
            entry.status == 'Entregue' ||
            entry.status == 'Concluída';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Detalhes do pedido',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 0,
                color: const Color(0xFFEAF8F3),
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF0A966A),
                  ),
                  title: Text(
                    entry.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(entry.dateLabel),
                  trailing: Text(
                    entry.totalLabel,
                    style: const TextStyle(
                      color: Color(0xFF0A966A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _DetailTile(
                label: 'Medicamento',
                value: entry.medicine,
                icon: Icons.medication_rounded,
              ),
              _DetailTile(
                label: 'Farmácia',
                value: entry.pharmacy,
                icon: Icons.local_pharmacy_outlined,
              ),
              _DetailTile(
                label: 'Quantidade',
                value: entry.quantity.toString(),
                icon: Icons.inventory_2_outlined,
              ),
              _DetailTile(
                label: 'Modalidade',
                value: entry.mode,
                icon: entry.mode == 'Delivery'
                    ? Icons.local_shipping_outlined
                    : Icons.shopping_bag_outlined,
              ),
              _DetailTile(
                label: 'Pagamento',
                value: entry.payment,
                icon: Icons.payments_outlined,
              ),
              if (entry.address != null)
                _DetailTile(
                  label: 'Endereço',
                  value: entry.address!,
                  icon: Icons.location_on_outlined,
                ),
              if (entry.isPickup)
                _DetailTile(
                  label: 'Responsável pela retirada',
                  value: entry.authorizedPickupName ??
                      'Titular da conta',
                  icon: Icons.person_outline_rounded,
                ),
              if (entry.isPickup &&
                  entry.authorizedPickupPhone != null)
                _DetailTile(
                  label: 'Telefone autorizado',
                  value: entry.authorizedPickupPhone!,
                  icon: Icons.phone_outlined,
                ),
              const SizedBox(height: 18),
              const Text(
                'Acompanhamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (isCancelled)
                const Card(
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(Icons.cancel_outlined, color: Colors.red),
                    title: Text('Pedido cancelado'),
                  ),
                )
              else
                ...List.generate(steps.length, (index) {
                  final done = currentIndex >= index;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: done
                          ? const Color(0xFF0A966A)
                          : Colors.black38,
                    ),
                    title: Text(
                      steps[index],
                      style: TextStyle(
                        fontWeight:
                            done ? FontWeight.w800 : FontWeight.w400,
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              if (!isFinished)
                FilledButton.icon(
                  onPressed: () => _advance(entry),
                  icon: Icon(
                    entry.isPickup
                        ? Icons.local_pharmacy_outlined
                        : Icons.skip_next_rounded,
                  ),
                  label: Text(
                    entry.isPickup
                        ? 'Simular confirmação da farmácia'
                        : 'Avançar status (simulação)',
                  ),
                ),
              if (entry.isPickup && !isFinished) ...[
                const SizedBox(height: 8),
                const Card(
                  elevation: 0,
                  color: Color(0xFFEAF8F3),
                  child: ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF0A966A),
                    ),
                    title: Text(
                      'Na operação real, a farmácia confirma a retirada '
                      'após conferir o responsável no balcão.',
                    ),
                  ),
                ),
              ],
              if (!isFinished) const SizedBox(height: 8),
              if (!isFinished)
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancelar pedido?'),
                        content: const Text(
                          'Esta ação é apenas uma simulação acadêmica.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Voltar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Cancelar pedido'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await DemoAppState.instance.updateOrderStatus(
                        entry.orderNumber,
                        'Cancelado',
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar pedido'),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultsPage(
                        medicine: entry.medicine,
                        city: 'Arapiraca - AL',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Pedir novamente'),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0A966A)),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
