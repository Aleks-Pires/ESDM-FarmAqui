import 'package:flutter/material.dart';

import '../../../../core/demo_app_state.dart';
import '../../../../core/medication_catalog.dart';
import '../../data/models/medication_offer.dart';
import '../../data/services/medication_service.dart';
import 'medication_details_page.dart';
import 'pharmacy_map_page.dart';
import 'reservation_page.dart';

final class ResultsPage extends StatefulWidget {
  const ResultsPage({
    required this.medicine,
    required this.city,
    super.key,
  });

  final String medicine;
  final String city;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

final class _ResultsPageState extends State<ResultsPage> {
  final service = MedicationService();
  late Future<MedicationSearchResult> futureResult;

  String sortMode = 'price';
  bool onlyDelivery = false;
  bool onlyInStock = false;
  bool onlyNoPrescription = false;
  bool maxTwenty = false;

  @override
  void initState() {
    super.initState();
    futureResult = service.search(
      medicine: widget.medicine,
      city: widget.city,
    );
  }

  void retry() {
    setState(() {
      futureResult = service.search(
        medicine: widget.medicine,
        city: widget.city,
      );
    });
  }

  double distanceValue(MedicationOffer offer) {
    final normalized = offer.distance
        .toLowerCase()
        .replaceAll('km', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized) ?? 9999;
  }

  List<MedicationOffer> filteredOffers(MedicationSearchResult result) {
    final offers = result.offers.where((offer) {
      if (onlyDelivery && !offer.delivery) return false;
      if (onlyInStock &&
          offer.status.toLowerCase().contains('indispon')) {
        return false;
      }
      if (onlyNoPrescription && offer.prescriptionRequired) return false;
      if (maxTwenty && offer.price > 20) return false;
      return true;
    }).toList();

    offers.sort((a, b) {
      if (sortMode == 'distance') {
        return distanceValue(a).compareTo(distanceValue(b));
      }

      if (sortMode == 'favorites') {
        final af = DemoAppState.instance.isFavorite(a.pharmacy) ? 0 : 1;
        final bf = DemoAppState.instance.isFavorite(b.pharmacy) ? 0 : 1;
        final favoriteCompare = af.compareTo(bf);
        if (favoriteCompare != 0) return favoriteCompare;
      }

      return a.price.compareTo(b.price);
    });

    return offers;
  }

  void clearFilters() {
    setState(() {
      onlyDelivery = false;
      onlyInStock = false;
      onlyNoPrescription = false;
      maxTwenty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Resultados',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: retry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<MedicationSearchResult>(
        future: futureResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorState(onRetry: retry);
          }

          final result = snapshot.data!;

          return AnimatedBuilder(
            animation: DemoAppState.instance,
            builder: (context, _) {
              final offers = filteredOffers(result);
              final allPrices =
                  result.offers.map((offer) => offer.price).toList()..sort();
              final lowestPrice =
                  allPrices.isEmpty ? 0.0 : allPrices.first;
              final highestPrice =
                  allPrices.isEmpty ? 0.0 : allPrices.last;
              final possibleSaving = highestPrice - lowestPrice;

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  Card(
                    elevation: 0,
                    color: const Color(0xFFEAF8F3),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.medication_rounded,
                          color: Color(0xFF0A966A),
                        ),
                      ),
                      title: Text(
                        result.medicine,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(result.city),
                      trailing: IconButton(
                        tooltip: DemoAppState.instance
                                .isMedicineFavorite(result.medicine)
                            ? 'Remover medicamento dos favoritos'
                            : 'Favoritar medicamento',
                        onPressed: () => DemoAppState.instance
                            .toggleMedicineFavorite(result.medicine),
                        icon: Icon(
                          DemoAppState.instance
                                  .isMedicineFavorite(result.medicine)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: DemoAppState.instance
                                  .isMedicineFavorite(result.medicine)
                              ? Colors.redAccent
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SourceBadge(source: result.source),
                  const SizedBox(height: 14),
                  if (result.offers.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MedicationDetailsPage(
                              medicine: result.medicine,
                              offers: result.offers,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('Detalhes do medicamento'),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ordenar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Menor preço'),
                        selected: sortMode == 'price',
                        onSelected: (_) =>
                            setState(() => sortMode = 'price'),
                      ),
                      ChoiceChip(
                        label: const Text('Mais perto'),
                        selected: sortMode == 'distance',
                        onSelected: (_) =>
                            setState(() => sortMode = 'distance'),
                      ),
                      ChoiceChip(
                        label: const Text('Favoritos primeiro'),
                        selected: sortMode == 'favorites',
                        onSelected: (_) =>
                            setState(() => sortMode = 'favorites'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filtrar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Com delivery'),
                        selected: onlyDelivery,
                        onSelected: (value) =>
                            setState(() => onlyDelivery = value),
                      ),
                      FilterChip(
                        label: const Text('Em estoque'),
                        selected: onlyInStock,
                        onSelected: (value) =>
                            setState(() => onlyInStock = value),
                      ),
                      FilterChip(
                        label: const Text('Sem receita'),
                        selected: onlyNoPrescription,
                        onSelected: (value) =>
                            setState(() => onlyNoPrescription = value),
                      ),
                      FilterChip(
                        label: const Text('Até R\$ 20'),
                        selected: maxTwenty,
                        onSelected: (value) =>
                            setState(() => maxTwenty = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (result.offers.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PharmacyMapPage(
                              medicine: result.medicine,
                              city: result.city,
                              offers: offers.isEmpty
                                  ? result.offers
                                  : offers,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Ver farmácias no mapa'),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    offers.isEmpty
                        ? 'Nenhuma farmácia com estes critérios'
                        : '${offers.length} farmácia(s) encontrada(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (result.offers.isEmpty)
                    _NoMedicationResult(
                      medicine: widget.medicine,
                      city: widget.city,
                    )
                  else if (offers.isEmpty)
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Há ofertas para este medicamento, mas nenhuma '
                              'passou pelos filtros selecionados.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: clearFilters,
                              child: const Text('Limpar filtros'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...offers.map(
                      (offer) => _OfferCard(
                        offer: offer,
                        medicine: result.medicine,
                        city: result.city,
                        isFavorite:
                            DemoAppState.instance.isFavorite(offer.pharmacy),
                        onFavorite: () => DemoAppState.instance
                            .toggleFavorite(offer.pharmacy),
                        saving: offer.price == lowestPrice
                            ? possibleSaving
                            : 0,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

final class _NoMedicationResult extends StatelessWidget {
  const _NoMedicationResult({
    required this.medicine,
    required this.city,
  });

  final String medicine;
  final String city;

  @override
  Widget build(BuildContext context) {
    final alternatives = alternativePresentations(medicine);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Não encontramos exatamente esta apresentação.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Talvez você esteja procurando:'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alternatives
                    .map(
                      (item) => ActionChip(
                        label: Text(item),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ResultsPage(
                                medicine: item,
                                city: city,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Tente pesquisar outro nome ou selecionar uma sugestão na busca.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final isApi = source == 'mock-api';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isApi
              ? const Color(0xFFE7F4FF)
              : const Color(0xFFFFF4DC),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          isApi
              ? 'Dados recebidos da API simulada'
              : 'Modo offline: JSON local',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

final class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.medicine,
    required this.city,
    required this.isFavorite,
    required this.onFavorite,
    required this.saving,
  });

  final MedicationOffer offer;
  final String medicine;
  final String city;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final double saving;

  String get price =>
      'R\$ ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final statusColor = offer.status.toLowerCase().contains('últimas')
        ? const Color(0xFFE28A00)
        : const Color(0xFF0A966A);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF8F3),
                  child: Icon(
                    Icons.local_pharmacy_rounded,
                    color: Color(0xFF0A966A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    offer.pharmacy,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(offer.distance),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remover dos favoritos'
                      : 'Favoritar farmácia',
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(24),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    offer.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF0A966A),
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            if (saving > 0.009) ...[
              const SizedBox(height: 8),
              Text(
                'Melhor preço: economize até R\$ ' +
                    saving.toStringAsFixed(2).replaceAll('.', ',') +
                    ' em relação à opção mais cara.',
                style: const TextStyle(
                  color: Color(0xFF0A966A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  offer.prescriptionRequired
                      ? Icons.receipt_long_outlined
                      : Icons.check_circle_outline_rounded,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(child: Text(offer.detail)),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReservationPage(
                      pharmacy: offer.pharmacy,
                      medicine: medicine,
                      city: city,
                      price: price,
                      deliveryAvailable: offer.delivery,
                      prescriptionRequired: offer.prescriptionRequired,
                      stockStatus: offer.status,
                    ),
                  ),
                );
              },
              child: Text(
                offer.delivery ? 'Reservar / Entrega' : 'Reservar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar os resultados.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
