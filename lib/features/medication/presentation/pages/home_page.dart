import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../profile/presentation/pages/profile_page.dart';
import 'history_page.dart';
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
  bool locating = false;
  int selectedIndex = 0;

  @override
  void dispose() {
    medicineController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> useCurrentLocation() async {
    if (locating) return;
    setState(() => locating = true);

    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permita o acesso à localização para usar este recurso.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      cityController.text =
          'Localização atual (${position.latitude.toStringAsFixed(3)}, '
          '${position.longitude.toStringAsFixed(3)})';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização obtida com sucesso.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter a localização agora.'),
        ),
      );
    } finally {
      if (mounted) setState(() => locating = false);
    }
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
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ListView(
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
              labelText: 'Cidade ou localização',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: locating ? null : useCurrentLocation,
            icon: locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(locating ? 'Obtendo localização...' : 'Usar minha localização'),
          ),
          const SizedBox(height: 12),
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
              'Os resultados desta versão são demonstrativos. Quando disponível, '
              'você pode simular reserva, retirada, entrega e pagamento.',
            ),
          ),
            ],
          ),
          const HistoryPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Histórico'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
