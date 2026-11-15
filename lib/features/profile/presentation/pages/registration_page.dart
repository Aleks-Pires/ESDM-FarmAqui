import 'package:flutter/material.dart';

import '../../../auth/data/clients/auth_api_client.dart';

final class RegisteredCredentials {
  const RegisteredCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

final class RegistrationPage extends StatefulWidget {
  const RegistrationPage({required this.authApi, super.key});

  final AuthApiClient authApi;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

final class _RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final susController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String payment = 'Cartão de crédito';
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    susController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  Future<void> finish() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await widget.authApi.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        cpf: cpfController.text,
        susCard: susController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(
        RegisteredCredentials(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar a conta.')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
              controller: nameController,
              label: 'Nome completo',
              icon: Icons.person_outline_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: cpfController,
              label: 'CPF',
              hint: '000.000.000-00',
              icon: Icons.badge_outlined,
              validator: requiredField,
              keyboardType: TextInputType.number,
            ),
            _Field(
              controller: susController,
              label: 'Cartão do SUS',
              hint: '0000 0000 0000 0000',
              icon: Icons.health_and_safety_outlined,
              validator: requiredField,
              keyboardType: TextInputType.number,
            ),
            _Field(
              controller: emailController,
              label: 'E-mail',
              icon: Icons.mail_outline_rounded,
              validator: (value) {
                final error = requiredField(value);
                if (error != null) return error;
                if (!(value ?? '').contains('@')) return 'Informe um e-mail válido.';
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              controller: passwordController,
              label: 'Senha',
              icon: Icons.lock_outline_rounded,
              validator: (value) {
                final error = requiredField(value);
                if (error != null) return error;
                if ((value ?? '').length < 6) {
                  return 'Use pelo menos 6 caracteres.';
                }
                return null;
              },
              obscureText: true,
            ),
            _Field(
              controller: confirmController,
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
                onChanged: loading
                    ? null
                    : (value) => setState(() => payment = value ?? payment),
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
              onPressed: loading ? null : finish,
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
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
        controller: controller,
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
