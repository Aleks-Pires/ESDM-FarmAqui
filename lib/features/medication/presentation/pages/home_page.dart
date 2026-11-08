import 'package:flutter/material.dart';

import '../../../profile/presentation/pages/profile_page.dart';
import 'results_page.dart';

final class HomePage extends StatefulWidget {
  const HomePage({required this.onLogout, super.key});
  final Future<void> Function() onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

final class _HomePageState extends State<HomePage> {
  final medicineController = TextEditingController();
  final cityController = TextEditingController(text: 'Arapiraca - AL');

  @override
  void dispose() {
    medicineController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void search([String? preset]) {
    final medicine = (preset ?? medicineController.text).trim();
    final city = cityController.text.trim();
    if (medicine.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o medicamento e a cidade.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsPage(medicine: medicine, city: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication_rounded, color: green),
            SizedBox(width: 8),
            Text('FarmaAqui', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Encontre seu medicamento antes de se deslocar.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10243B),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pesquise o medicamento e veja opções disponíveis na sua região.',
          ),
          const SizedBox(height: 28),
          TextField(
            controller: medicineController,
            decoration: const InputDecoration(
              labelText: 'Qual medicamento você procura?',
              hintText: 'Ex.: Losartana 50 mg',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: cityController,
            onSubmitted: (_) => search(),
            decoration: const InputDecoration(
              labelText: 'Cidade',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: search,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Buscar'),
          ),
          const SizedBox(height: 28),
          const Text(
            'Buscas recentes',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...['Dipirona 500 mg', 'Insulina', 'Amoxicilina'].map(
            (item) => Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.history_rounded, color: green),
                title: Text(item),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  medicineController.text = item;
                  search(item);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Quando disponível, você poderá reservar o medicamento para retirada ou solicitar entrega.',
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfilePage(),
              ),
            );
          }
        },
        destinations: [
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded), label: 'Histórico'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
