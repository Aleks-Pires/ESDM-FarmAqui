import 'package:flutter/material.dart';

final class ReservationPage extends StatefulWidget {
  const ReservationPage({
    required this.pharmacy,
    required this.medicine,
    required this.city,
    required this.price,
    super.key,
  });

  final String pharmacy;
  final String medicine;
  final String city;
  final String price;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

final class _ReservationPageState extends State<ReservationPage> {
  int quantity = 1;
  bool delivery = false;
  String payment = 'Cartão de crédito';

  void confirm() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF0A966A),
          size: 48,
        ),
        title: const Text('Reserva confirmada'),
        content: Text(
          delivery
              ? 'Pedido registrado. Previsão de entrega: aproximadamente 45 minutos.'
              : 'Pedido registrado e disponível para retirada hoje.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  double get unitPrice {
    final normalized = widget.price
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized) ?? 0;
  }

  String brl(double value) {
    return 'R\$ ' + value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = unitPrice * quantity;
    final deliveryFee = delivery ? 5.90 : 0.0;
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
                      child: Icon(Icons.local_pharmacy_rounded, color: Color(0xFF0A966A)),
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
                      child: Icon(Icons.medication_rounded, color: Color(0xFF0A966A)),
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
                  icon: Icons.local_shipping_outlined,
                  title: 'Entrega',
                  subtitle: 'Previsão: 45 min',
                  onTap: () => setState(() => delivery = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Forma de pagamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...['Cartão de crédito', 'Cartão de débito', 'Pix'].map(
            (method) => RadioListTile<String>(
              value: method,
              groupValue: payment,
              onChanged: (value) => setState(() => payment = value ?? payment),
              title: Text(method),
              secondary: Icon(
                method == 'Pix'
                    ? Icons.pix_rounded
                    : Icons.credit_card_rounded,
              ),
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
            onPressed: confirm,
            icon: const Icon(Icons.lock_outline_rounded),
            label: Text(delivery ? 'Confirmar pedido' : 'Confirmar reserva'),
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
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF8F3) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? green : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12.5)),
          ],
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
