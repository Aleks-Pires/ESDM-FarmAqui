import 'package:flutter/material.dart';

final class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final class _ProfilePageState extends State<ProfilePage> {
  String name = 'Usuário FarmaAqui';
  String email = 'usuario@farmaaqui.app';
  String phone = '(82) 99999-0000';
  String address = 'Não informado';

  Future<void> editField({required String title, required String currentValue, required ValueChanged<String> onSave, TextInputType? keyboardType}) async {
    final controller = TextEditingController(text: currentValue == 'Não informado' ? '' : currentValue);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, keyboardType: keyboardType, autofocus: true, decoration: InputDecoration(hintText: title, border: const OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !mounted) return;
    setState(() => onSave(value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title + ' atualizado com sucesso.')));
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text('Perfil', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF10243B))),
        const SizedBox(height: 18),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          const CircleAvatar(radius: 34, backgroundColor: Color(0xFFEAF8F3), child: Icon(Icons.person_rounded, size: 36, color: green)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(email),
            const SizedBox(height: 4),
            const Text('Conta demonstrativa', style: TextStyle(fontSize: 12)),
          ])),
        ]))),
        const SizedBox(height: 20),
        const Text('Suas estatísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const Row(children: [
          Expanded(child: _StatCard(value: '12', label: 'Buscas', icon: Icons.search_rounded)),
          SizedBox(width: 10),
          Expanded(child: _StatCard(value: '4', label: 'Reservas', icon: Icons.shopping_bag_outlined)),
          SizedBox(width: 10),
          Expanded(child: _StatCard(value: '2', label: 'Entregas', icon: Icons.local_shipping_outlined)),
        ]),
        const SizedBox(height: 22),
        const Text('Informações da conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _EditTile(icon: Icons.person_outline_rounded, title: 'Nome', value: name, onTap: () => editField(title: 'Nome', currentValue: name, onSave: (value) => name = value)),
        _EditTile(icon: Icons.mail_outline_rounded, title: 'E-mail', value: email, onTap: () => editField(title: 'E-mail', currentValue: email, keyboardType: TextInputType.emailAddress, onSave: (value) => email = value)),
        _EditTile(icon: Icons.phone_outlined, title: 'Telefone', value: phone, onTap: () => editField(title: 'Telefone', currentValue: phone, keyboardType: TextInputType.phone, onSave: (value) => phone = value)),
        _EditTile(icon: Icons.home_outlined, title: 'Endereço', value: address, onTap: () => editField(title: 'Endereço', currentValue: address, onSave: (value) => address = value)),
        _EditTile(icon: Icons.lock_outline_rounded, title: 'Senha', value: 'Alterar senha', onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alteração de senha simulada nesta versão acadêmica.')));
        }),
      ],
    );
  }
}

final class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);
    return Card(elevation: 0, color: const Color(0xFFEAF8F3), child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(children: [
        Icon(icon, color: green),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: green)),
        Text(label, style: const TextStyle(fontSize: 12.5)),
      ]),
    ));
  }
}

final class _EditTile extends StatelessWidget {
  const _EditTile({required this.icon, required this.title, required this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), child: ListTile(
      leading: Icon(icon, color: const Color(0xFF0A966A)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_outlined),
      onTap: onTap,
    ));
  }
}
