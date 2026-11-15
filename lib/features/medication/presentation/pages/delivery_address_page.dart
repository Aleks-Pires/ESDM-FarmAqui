import 'package:flutter/material.dart';

final class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({super.key});

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

final class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  final formKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final complementController = TextEditingController();

  @override
  void dispose() {
    streetController.dispose();
    numberController.dispose();
    neighborhoodController.dispose();
    complementController.dispose();
    super.dispose();
  }

  String? requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  void confirm() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final parts = <String>[
      streetController.text.trim(),
      'nº ${numberController.text.trim()}',
      neighborhoodController.text.trim(),
      'Arapiraca/AL',
    ];

    if (complementController.text.trim().isNotEmpty) {
      parts.insert(2, complementController.text.trim());
    }

    Navigator.of(context).pop(parts.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Endereço de entrega',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Para solicitar delivery, informe onde o medicamento deve ser entregue.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: streetController,
              validator: requiredField,
              decoration: const InputDecoration(
                labelText: 'Rua ou avenida',
                prefixIcon: Icon(Icons.route_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: numberController,
              validator: requiredField,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número',
                prefixIcon: Icon(Icons.numbers_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: neighborhoodController,
              validator: requiredField,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: complementController,
              decoration: const InputDecoration(
                labelText: 'Complemento (opcional)',
                prefixIcon: Icon(Icons.home_work_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              elevation: 0,
              color: Color(0xFFEAF8F3),
              child: ListTile(
                leading: Icon(Icons.local_shipping_outlined),
                title: Text('Taxa de entrega'),
                subtitle: Text('Valor fixo para a simulação em Arapiraca'),
                trailing: Text(
                  'R$ 6,90',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A966A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: confirm,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Confirmar endereço'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
