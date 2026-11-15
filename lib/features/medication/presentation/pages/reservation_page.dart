import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';

import '../../data/services/medication_service.dart';
import 'delivery_address_page.dart';

final class ReservationPage extends StatefulWidget {
  const ReservationPage({
    required this.pharmacy,
    required this.medicine,
    required this.city,
    required this.price,
    required this.deliveryAvailable,
    required this.prescriptionRequired,
    super.key,
  });

  final String pharmacy;
  final String medicine;
  final String city;
  final String price;
  final bool deliveryAvailable;
  final bool prescriptionRequired;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

final class _ReservationPageState extends State<ReservationPage> {
  final service = MedicationService();

  int quantity = 1;
  bool delivery = false;
  bool prescriptionAttached = false;
  bool confirming = false;
  String? deliveryAddress;
  String payment = 'Cartão de crédito';

  double get unitPrice {
    final normalized = widget.price
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0;
  }

  String brl(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String generateOrderNumber() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final time =
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final millis = now.millisecond.toString().padLeft(3, '0');
    return 'FA-${now.year}${two(now.month)}${two(now.day)}-$time$millis';
  }

  Future<void> confirm() async {
    if (delivery && (deliveryAddress == null || deliveryAddress!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o endereço para solicitar delivery.'),
        ),
      );
      return;
    }

    if (widget.prescriptionRequired && !prescriptionAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este medicamento exige receita. Anexe a prescrição para continuar.',
          ),
        ),
      );
      return;
    }

    setState(() => confirming = true);

    try {
      final success = await service.createReservation(
        pharmacy: widget.pharmacy,
        medicine: widget.medicine,
        quantity: quantity,
        delivery: delivery,
        payment: payment,
      );

      if (!mounted || !success) return;

      final subtotal = unitPrice * quantity;
      final deliveryFee = delivery ? 6.90 : 0.0;
      final total = subtotal + deliveryFee;

      final orderNumber = generateOrderNumber();

      DemoAppState.instance.addHistory(
        HistoryEntry(
          medicine: widget.medicine,
          pharmacy: widget.pharmacy,
          mode: delivery ? 'Delivery' : 'Retirada',
          status: delivery ? 'Pedido confirmado' : 'Reserva confirmada',
          dateLabel: 'Agora',
          totalLabel: brl(total),
          orderNumber: orderNumber,
        ),
      );

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF0A966A),
            size: 48,
          ),
          title: Text(delivery ? 'Pedido confirmado' : 'Reserva confirmada'),
          content: Text(
            (delivery
                    ? 'Pagamento simulado aprovado. Previsão de entrega: aproximadamente 45 minutos.'
                    : 'Pagamento simulado aprovado. Medicamento reservado para retirada hoje.') +
                '\n\nNúmero do pedido: ' +
                orderNumber,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Concluir'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } finally {
      if (mounted) setState(() => confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = unitPrice * quantity;
    final deliveryFee = delivery ? 6.90 : 0.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Reserva e pagamento',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF8F3),
                      child: Icon(
                        Icons.local_pharmacy_rounded,
                        color: Color(0xFF0A966A),
                      ),
                    ),
                    title: Text(
                      widget.pharmacy,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(widget.city),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF8F3),
                      child: Icon(
                        Icons.medication_rounded,
                        color: Color(0xFF0A966A),
                      ),
                    ),
                    title: Text(
                      widget.medicine,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text('Caixa com 30 comprimidos'),
                    trailing: Text(
                      widget.price,
                      style: const TextStyle(
                        color: Color(0xFF0A966A),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quantidade de unidades',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.prescriptionRequired) ...[
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              color: prescriptionAttached
                  ? const Color(0xFFEAF8F3)
                  : const Color(0xFFFFF4DC),
              child: ListTile(
                leading: Icon(
                  prescriptionAttached
                      ? Icons.verified_rounded
                      : Icons.receipt_long_outlined,
                  color: prescriptionAttached
                      ? const Color(0xFF0A966A)
                      : const Color(0xFFE28A00),
                ),
                title: Text(
                  prescriptionAttached
                      ? 'Receita anexada'
                      : 'Receita obrigatória',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Simulação de envio e validação da prescrição.',
                ),
                trailing: TextButton(
                  onPressed: () {
                    setState(() => prescriptionAttached = true);
                  },
                  child: Text(
                    prescriptionAttached ? 'Validada' : 'Anexar',
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Como você quer receber?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ReceiveOption(
                  selected: !delivery,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Retirada',
                  subtitle: 'Disponível hoje',
                  onTap: () => setState(() => delivery = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReceiveOption(
                  selected: delivery,
                  enabled: widget.deliveryAvailable,
                  icon: Icons.local_shipping_outlined,
                  title: 'Entrega',
                  subtitle: widget.deliveryAvailable
                      ? 'Previsão: 45 min'
                      : 'Indisponível',
                  onTap: () async {
                    if (!widget.deliveryAvailable) return;

                    final address = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const DeliveryAddressPage(),
                      ),
                    );

                    if (address == null || !mounted) return;

                    setState(() {
                      delivery = true;
                      deliveryAddress = address;
                    });
                  },
                ),
              ),
            ],
          ),
          if (delivery && deliveryAddress != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: const Color(0xFFEAF8F3),
              child: ListTile(
                leading: const Icon(Icons.location_on_rounded),
                title: const Text(
                  'Endereço de entrega',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(deliveryAddress!),
                trailing: TextButton(
                  onPressed: () async {
                    final address = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const DeliveryAddressPage(),
                      ),
                    );
                    if (address != null && mounted) {
                      setState(() => deliveryAddress = address);
                    }
                  },
                  child: const Text('Alterar'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Forma de pagamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...['Cartão de crédito', 'Cartão de débito', 'Pix'].map(
            (method) => ListTile(
              leading: Icon(
                method == 'Pix'
                    ? Icons.pix_rounded
                    : Icons.credit_card_rounded,
              ),
              title: Text(method),
              trailing: Radio<String>(
                value: method,
                groupValue: payment,
                onChanged: (value) {
                  if (value != null) setState(() => payment = value);
                },
              ),
              onTap: () => setState(() => payment = method),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: brl(subtotal)),
                  if (delivery)
                    _SummaryRow(
                      label: 'Taxa de entrega',
                      value: brl(deliveryFee),
                    ),
                  const _SummaryRow(
                    label: 'Taxa de serviço',
                    value: 'R\$ 0,00',
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Total',
                    value: brl(total),
                    strong: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0A966A),
            ),
            onPressed: confirming ? null : confirm,
            icon: confirming
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline_rounded),
            label: Text(
              confirming
                  ? 'Processando...'
                  : delivery
                      ? 'Pagar e confirmar pedido'
                      : 'Pagar e confirmar reserva',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pagamento e validação de receita são simulados para fins acadêmicos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

final class _ReceiveOption extends StatelessWidget {
  const _ReceiveOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF8F3) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? green : Colors.black12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: green),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: strong ? FontWeight.w900 : FontWeight.w400,
      fontSize: strong ? 18 : 14,
      color: strong ? const Color(0xFF0A966A) : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
