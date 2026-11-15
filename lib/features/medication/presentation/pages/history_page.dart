import 'package:flutter/material.dart';

final class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    const items = [
      _HistoryItem(medicine: 'Losartana 50 mg', pharmacy: 'Farmácia Agreste', mode: 'Delivery', status: 'Entregue', date: 'Hoje, 14:20', total: 'R\$ 25,80', icon: Icons.local_shipping_outlined),
      _HistoryItem(medicine: 'Dipirona 500 mg', pharmacy: 'Drogaria Bom Sucesso', mode: 'Retirada', status: 'Concluída', date: '12/11/2026, 10:05', total: 'R\$ 8,90', icon: Icons.shopping_bag_outlined),
      _HistoryItem(medicine: 'Paracetamol 750 mg', pharmacy: 'Farmácia Avenida', mode: 'Delivery', status: 'Concluída', date: '08/11/2026, 18:42', total: 'R\$ 17,80', icon: Icons.local_shipping_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text('Histórico', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF10243B))),
        const SizedBox(height: 6),
        const Text('Acompanhe suas reservas, retiradas e pedidos anteriores.'),
        const SizedBox(height: 22),
        ...items.map((item) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(backgroundColor: const Color(0xFFEAF8F3), child: Icon(item.icon, color: green)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.medicine, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(item.pharmacy),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEAF8F3), borderRadius: BorderRadius.circular(20)),
                    child: Text(item.status, style: const TextStyle(color: green, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text(item.mode + ' • ' + item.date)),
                  Text(item.total, style: const TextStyle(fontWeight: FontWeight.w900, color: green)),
                ]),
              ],
            ),
          ),
        )),
        const SizedBox(height: 8),
        const Card(
          elevation: 0,
          color: Color(0xFFF2F7F5),
          child: ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Histórico demonstrativo'),
            subtitle: Text('Os pedidos exibidos nesta versão são simulados para a apresentação acadêmica.'),
          ),
        ),
      ],
    );
  }
}

final class _HistoryItem {
  const _HistoryItem({required this.medicine, required this.pharmacy, required this.mode, required this.status, required this.date, required this.total, required this.icon});
  final String medicine;
  final String pharmacy;
  final String mode;
  final String status;
  final String date;
  final String total;
  final IconData icon;
}
