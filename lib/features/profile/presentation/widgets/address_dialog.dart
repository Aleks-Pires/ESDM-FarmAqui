import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

final class _AddressDialogState extends State<AddressDialog> {
  static const states = <String, String>{
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  final formKey = GlobalKey<FormState>();
  final neighborhoodController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final blockController = TextEditingController();
  final complementController = TextEditingController();

  String? stateCode;
  String? city;
  List<String> cities = [];
  bool loadingCities = false;
  String? citiesError;

  @override
  void dispose() {
    neighborhoodController.dispose();
    streetController.dispose();
    numberController.dispose();
    blockController.dispose();
    complementController.dispose();
    super.dispose();
  }

  Future<void> loadCities(String value) async {
    setState(() {
      stateCode = value;
      city = null;
      cities = [];
      citiesError = null;
      loadingCities = true;
    });

    try {
      final uri = Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$value/municipios?orderBy=nome',
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Falha ao carregar municípios');
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final loaded = decoded
          .map((item) => (item as Map<String, dynamic>)['nome'] as String)
          .toList();

      if (!mounted) return;

      setState(() {
        cities = loaded;
        loadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        citiesError =
            'Não foi possível carregar os municípios. Tente novamente.';
        loadingCities = false;
      });
    }
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (stateCode == null || city == null) return;

    final parts = <String>[
      streetController.text.trim(),
      numberController.text.trim().toUpperCase(),
    ];

    if (blockController.text.trim().isNotEmpty) {
      parts.add('Quadra ' + blockController.text.trim());
    }

    if (complementController.text.trim().isNotEmpty) {
      parts.add(complementController.text.trim());
    }

    parts.add(neighborhoodController.text.trim());
    parts.add(city!);
    parts.add(states[stateCode]!);

    Navigator.of(context).pop(parts.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Endereço'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: stateCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    hintText: 'Selecione o estado',
                    border: OutlineInputBorder(),
                  ),
                  items: states.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text('${entry.value} (${entry.key})'),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Selecione o estado.' : null,
                  onChanged: (value) {
                    if (value != null) loadCities(value);
                  },
                ),
                const SizedBox(height: 12),
                if (loadingCities)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Carregando municípios...'),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: city,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Cidade',
                      hintText: stateCode == null
                          ? 'Selecione primeiro o estado'
                          : 'Selecione a cidade',
                      border: const OutlineInputBorder(),
                      errorText: citiesError,
                    ),
                    items: cities
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Selecione a cidade.' : null,
                    onChanged: stateCode == null || cities.isEmpty
                        ? null
                        : (value) => setState(() => city = value),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: neighborhoodController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Informe o bairro.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro',
                    hintText: 'Rua, avenida, travessa...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Informe o logradouro.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: numberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    hintText: 'Ex.: 20, 20A ou SN',
                    helperText: 'Use SN para endereço sem número.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim().toUpperCase();
                    if (text.isEmpty) return 'Informe o número ou SN.';
                    if (!RegExp(r'^[0-9A-Z]+$').hasMatch(text)) {
                      return 'Use apenas letras e números.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: blockController,
                  decoration: const InputDecoration(
                    labelText: 'Quadra (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: complementController,
                  decoration: const InputDecoration(
                    labelText: 'Complemento (opcional)',
                    hintText: 'Apartamento, casa, referência...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
