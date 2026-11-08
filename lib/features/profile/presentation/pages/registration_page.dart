import 'package:flutter/material.dart';

final class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

final class _RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();
  String payment = 'Cartão de crédito';

  String? requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  void finish() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro preenchido. Integração com backend será a próxima etapa.'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Criar conta',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Color(0xFFEAF8F3),
                    child: Icon(Icons.person_rounded, size: 48, color: green),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicionar foto',
                    style: TextStyle(color: green, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Field(
              label: 'Nome completo',
              icon: Icons.person_outline_rounded,
              validator: requiredField,
            ),
            _Field(
              label: 'CPF',
              hint: '000.000.000-00',
              icon: Icons.badge_outlined,
              validator: requiredField,
            ),
            _Field(
              label: 'Cartão do SUS',
              hint: '0000 0000 0000 0000',
              icon: Icons.health_and_safety_outlined,
              validator: requiredField,
            ),
            _Field(
              label: 'E-mail',
              icon: Icons.mail_outline_rounded,
              validator: requiredField,
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              label: 'Senha',
              icon: Icons.lock_outline_rounded,
              validator: requiredField,
              obscureText: true,
            ),
            _Field(
              label: 'Confirmar senha',
              icon: Icons.lock_outline_rounded,
              validator: requiredField,
              obscureText: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Forma de pagamento preferida',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            ...['Cartão de crédito', 'Cartão de débito'].map(
              (method) => RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: method,
                groupValue: payment,
                onChanged: (value) => setState(() => payment = value ?? payment),
                title: Text(method),
                secondary: const Icon(Icons.credit_card_rounded),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: finish,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.icon,
    required this.validator,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
