import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/demo_app_state.dart';
import '../../../../core/medication_catalog.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'authorize_pickup_page.dart';
import 'history_page.dart';
import 'order_details_page.dart';
import 'purchases_page.dart';
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
            content: Text(
              'Permita o acesso à localização para usar este recurso.',
            ),
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

    DemoAppState.instance.addRecentSearch(medicine);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsPage(medicine: medicine, city: city),
      ),
    );
  }

  Future<void> addReminder() async {
    final medicine = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('Lembrete de medicamento'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Medicamento',
              hintText: 'Ex.: Losartana 50 mg',
              prefixIcon: Icon(Icons.medication_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    if (medicine == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Horário do lembrete',
    );

    if (time == null) return;

    await DemoAppState.instance.addReminder(
      medicine: medicine,
      hour: time.hour,
      minute: time.minute,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Lembrete de $medicine salvo para ${time.format(context)}.',
        ),
      ),
    );
  }

  Widget buildHome() {
    const green = Color(0xFF0A966A);

    return ListView(
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
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) return const Iterable<String>.empty();
            return medicationSuggestionsFor(query);
          },
          displayStringForOption: (option) => option,
          onSelected: (selection) {
            medicineController.text = selection;
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            if (medicineController.text.isNotEmpty &&
                textEditingController.text.isEmpty) {
              textEditingController.text = medicineController.text;
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) => medicineController.text = value,
              onSubmitted: (_) => search(),
              decoration: const InputDecoration(
                labelText: 'Qual medicamento você procura?',
                hintText: 'Ex.: Losartana 50 mg',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
            );
          },
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
          label: Text(
            locating ? 'Obtendo localização...' : 'Usar minha localização',
          ),
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
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: DemoAppState.instance,
          builder: (context, _) {
            final state = DemoAppState.instance;
            HistoryEntry? pickup;
            for (final item in state.activePurchases) {
              if (item.mode == 'Retirada') {
                pickup = item;
                break;
              }
            }

            if (pickup == null) return const SizedBox.shrink();

            final pendingPickup = pickup;

            return Card(
              elevation: 0,
              color: const Color(0xFFEAF8F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: green),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Retirada aguardando',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10243B),
                                ),
                              ),
                              Text(pendingPickup.medicine),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            pendingPickup.status,
                            style: const TextStyle(
                              color: green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.local_pharmacy_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pendingPickup.pharmacy,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pendingPickup.authorizedPickupName == null
                          ? 'Retirada pelo titular da conta.'
                          : 'Retirada autorizada para '
                              '${pendingPickup.authorizedPickupName}.',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsPage(
                                    orderNumber: pendingPickup.orderNumber,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Ver detalhes'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AuthorizePickupPage(
                                    orderNumber: pendingPickup.orderNumber,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Autorizar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        const Text(
          'Favoritos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: DemoAppState.instance,
          builder: (context, _) {
            final favorites = DemoAppState.instance.favoriteMedicines.toList();

            if (favorites.isEmpty) {
              return const Text(
                'Favorite medicamentos nos resultados para acessá-los rapidamente aqui.',
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites
                  .map(
                    (medicine) => ActionChip(
                      avatar: const Icon(Icons.favorite_rounded, size: 17),
                      label: Text(medicine),
                      onPressed: () {
                        medicineController.text = medicine;
                        search(medicine);
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lembretes de medicamentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Adicionar lembrete',
              onPressed: addReminder,
              icon: const Icon(Icons.alarm_add_rounded, color: green),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: DemoAppState.instance,
          builder: (context, _) {
            final reminders = DemoAppState.instance.reminders;

            if (reminders.isEmpty) {
              return Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.alarm_outlined, color: green),
                  title: const Text('Nenhum lembrete configurado'),
                  subtitle: const Text(
                    'Adicione um horário para lembrar de tomar um medicamento.',
                  ),
                  trailing: TextButton(
                    onPressed: addReminder,
                    child: const Text('Adicionar'),
                  ),
                ),
              );
            }

            return Column(
              children: reminders
                  .map(
                    (reminder) => Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEAF8F3),
                          child: Icon(Icons.alarm_rounded, color: green),
                        ),
                        title: Text(
                          reminder.medicine,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          'Todos os dias às ${reminder.timeLabel}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: reminder.enabled,
                              onChanged: (_) {
                                DemoAppState.instance.toggleReminder(
                                  reminder.id,
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Excluir lembrete',
                              onPressed: () {
                                DemoAppState.instance.deleteReminder(
                                  reminder.id,
                                );
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Buscas recentes',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: DemoAppState.instance,
          builder: (context, _) {
            final recent = DemoAppState.instance.recentSearches;

            if (recent.isEmpty) {
              return const Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(Icons.history_rounded),
                  title: Text('Nenhuma busca recente ainda'),
                ),
              );
            }

            return Column(
              children: recent
                  .map(
                    (item) => Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const Icon(
                          Icons.history_rounded,
                          color: green,
                        ),
                        title: Text(item),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          medicineController.text = item;
                          search(item);
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8F3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Os resultados, pedidos e lembretes desta versão são '
            'demonstrativos para fins acadêmicos.',
          ),
        ),
      ],
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
            Text(
              'FarmaAqui',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
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
          buildHome(),
          const PurchasesPage(),
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
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Compras',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
