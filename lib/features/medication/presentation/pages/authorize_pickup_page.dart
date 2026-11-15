import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/demo_app_state.dart';

final class AuthorizePickupPage extends StatefulWidget {
  const AuthorizePickupPage({required this.orderNumber, super.key});
  final String orderNumber;

  @override
  State<AuthorizePickupPage> createState() => _AuthorizePickupPageState();
}

final class _AuthorizePickupPageState extends State<AuthorizePickupPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final phoneController = TextEditingController();
  final documentController = TextEditingController();
  final relationController = TextEditingController();

  bool authorized = false;
  bool saving = false;

  HistoryEntry? get order =>
      DemoAppState.instance.findOrder(widget.orderNumber);

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    documentController.dispose();
    relationController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false) || !authorized) {
      if (!authorized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Confirme a autorização para continuar.'),
          ),
        );
      }
      return;
    }

    setState(() => saving = true);

    await DemoAppState.instance.authorizePickup(
      orderNumber: widget.orderNumber,
      name: nameController.text.trim(),
      cpf: cpfController.text.trim(),
      phone: phoneController.text.trim(),
      document: documentController.text.trim(),
      relation: relationController.text.trim().isEmpty
          ? null
          : relationController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pessoa autorizada para retirada com sucesso.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);
    final currentOrder = order;

    if (currentOrder == null) {
      return const Scaffold(
        body: Center(child: Text('Reserva não encontrada.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Autorizar retirada',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Card(
              elevation: 0,
              color: const Color(0xFFEAF8F3),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.medication_rounded, color: green),
                ),
                title: Text(
                  currentOrder.medicine,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  currentOrder.pharmacy + '\n' + currentOrder.orderNumber,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Dados da pessoa autorizada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Informe quem irá retirar o medicamento em seu nome.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Informe o nome completo.'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 11,
              decoration: const InputDecoration(
                labelText: 'CPF',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) =>
                  value == null || value.length != 11
                      ? 'Informe os 11 dígitos do CPF.'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().length < 8
                      ? 'Informe um telefone válido.'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: documentController,
              decoration: const InputDecoration(
                labelText: 'Documento com foto',
                hintText: 'Ex.: RG ou CNH',
                prefixIcon: Icon(Icons.credit_card_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Informe o documento que será apresentado.'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: relationController,
              decoration: const InputDecoration(
                labelText: 'Parentesco / relação (opcional)',
                hintText: 'Ex.: filho(a), amigo(a), cuidador(a)',
                prefixIcon: Icon(Icons.groups_2_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: const Color(0xFFEAF8F3),
              child: CheckboxListTile(
                value: authorized,
                activeColor: green,
                title: const Text(
                  'Autorizo esta pessoa a retirar o medicamento em meu nome.',
                ),
                onChanged: (value) {
                  setState(() => authorized = value ?? false);
                },
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded, color: green),
                title: Text(
                  'Na retirada, a pessoa autorizada deverá apresentar documento '
                  'com foto e os dados informados nesta autorização.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: saving ? null : save,
              icon: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: Text(saving ? 'Salvando...' : 'Salvar autorização'),
            ),
          ],
        ),
      ),
    );
  }
}
