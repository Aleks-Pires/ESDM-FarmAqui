import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/address_dialog.dart';

final class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final class _ProfilePageState extends State<ProfilePage> {
  String name = 'Usuário FarmaAqui';
  String email = 'usuario@farmaaqui.app';
  String phone = '(82) 99999-0000';
  String address = 'Nenhum endereço cadastrado';
  Uint8List? profileImageBytes;

  static const String _defaultProfileImageBase64 = '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';

  MemoryImage get defaultProfileImage =>
      MemoryImage(base64Decode(_defaultProfileImageBase64));

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() => profileImageBytes = bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil atualizada.')),
    );
  }

  Future<void> editField({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController(
      text: currentValue == 'Não informado' ? '' : currentValue,
    );

    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (value == null || value.isEmpty || !mounted) return;

    setState(() => onSave(value));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title atualizado com sucesso.')),
    );
  }

  Future<void> editAddress() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const AddressDialog(),
    );

    if (result == null || !mounted) return;

    setState(() => address = result);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Endereço atualizado com sucesso.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF10243B),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFFEAF8F3),
                      backgroundImage: profileImageBytes == null
                          ? defaultProfileImage
                          : MemoryImage(profileImageBytes!),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Material(
                        color: green,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: pickProfilePhoto,
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email),
                      const SizedBox(height: 4),
                      const Text(
                        'Conta demonstrativa',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: pickProfilePhoto,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text('Trocar foto'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Suas estatísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '12',
                label: 'Buscas',
                icon: Icons.search_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '4',
                label: 'Reservas',
                icon: Icons.shopping_bag_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '2',
                label: 'Entregas',
                icon: Icons.local_shipping_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Informações da conta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _EditTile(
          icon: Icons.person_outline_rounded,
          title: 'Nome',
          value: name,
          onTap: () => editField(
            title: 'Nome',
            currentValue: name,
            onSave: (value) => name = value,
          ),
        ),
        _EditTile(
          icon: Icons.mail_outline_rounded,
          title: 'E-mail',
          value: email,
          onTap: () => editField(
            title: 'E-mail',
            currentValue: email,
            keyboardType: TextInputType.emailAddress,
            onSave: (value) => email = value,
          ),
        ),
        _EditTile(
          icon: Icons.phone_outlined,
          title: 'Telefone',
          value: phone,
          onTap: () => editField(
            title: 'Telefone',
            currentValue: phone,
            keyboardType: TextInputType.phone,
            onSave: (value) => phone = value,
          ),
        ),
        _EditTile(
          icon: Icons.home_outlined,
          title: 'Endereço',
          value: address,
          actionLabel:
              address == 'Nenhum endereço cadastrado' ? 'Adicionar' : 'Editar',
          onTap: editAddress,
        ),
        _EditTile(
          icon: Icons.lock_outline_rounded,
          title: 'Senha',
          value: 'Alterar senha',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Alteração de senha simulada nesta versão acadêmica.',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

final class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return Card(
      elevation: 0,
      color: const Color(0xFFEAF8F3),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(icon, color: green),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: green,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EditTile extends StatelessWidget {
  const _EditTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF0A966A),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(value),
        trailing: actionLabel == null
            ? const Icon(Icons.edit_outlined)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
