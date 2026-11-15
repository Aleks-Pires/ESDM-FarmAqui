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

  final neighborhoodController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final blockController = TextEditingController();
  final complementController = TextEditingController();

  final neighborhoodFocus = FocusNode();
  final streetFocus = FocusNode();
  final numberFocus = FocusNode();

  String? stateCode;
  String? city;
  List<String> cities = [];
  bool loadingCities = false;
  String? citiesError;

  String? activeError;

  @override
  void initState() {
    super.initState();

    neighborhoodFocus.addListener(() {
      if (!neighborhoodFocus.hasFocus &&
          neighborhoodController.text.trim().isEmpty) {
        setState(() => activeError = 'neighborhood');
      }
    });

    streetFocus.addListener(() {
      if (!streetFocus.hasFocus && streetController.text.trim().isEmpty) {
        setState(() => activeError = 'street');
      }
    });

    numberFocus.addListener(() {
      if (!numberFocus.hasFocus) {
        final value = numberController.text.trim().toUpperCase();
        if (value.isEmpty || !RegExp(r'^[0-9A-Z]+$').hasMatch(value)) {
          setState(() => activeError = 'number');
        }
      }
    });
  }

  @override
  void dispose() {
    neighborhoodController.dispose();
    streetController.dispose();
    numberController.dispose();
    blockController.dispose();
    complementController.dispose();
    neighborhoodFocus.dispose();
    streetFocus.dispose();
    numberFocus.dispose();
    super.dispose();
  }

  Future<void> loadCities(String value) async {
    setState(() {
      stateCode = value;
      city = null;
      cities = [];
      citiesError = null;
      loadingCities = true;
      if (activeError == 'state') activeError = null;
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

  void clearErrorWhenValid(String field) {
    if (activeError != field) return;

    var valid = false;

    if (field == 'neighborhood') {
      valid = neighborhoodController.text.trim().isNotEmpty;
    } else if (field == 'street') {
      valid = streetController.text.trim().isNotEmpty;
    } else if (field == 'number') {
      final value = numberController.text.trim().toUpperCase();
      valid = value.isNotEmpty && RegExp(r'^[0-9A-Z]+$').hasMatch(value);
    }

    if (valid) {
      setState(() => activeError = null);
    }
  }

  void save() {
    if (stateCode == null) {
      setState(() => activeError = 'state');
      return;
    }

    if (city == null) {
      setState(() => activeError = 'city');
      return;
    }

    if (neighborhoodController.text.trim().isEmpty) {
      setState(() => activeError = 'neighborhood');
      neighborhoodFocus.requestFocus();
      return;
    }

    if (streetController.text.trim().isEmpty) {
      setState(() => activeError = 'street');
      streetFocus.requestFocus();
      return;
    }

    final number = numberController.text.trim().toUpperCase();
    if (number.isEmpty) {
      setState(() => activeError = 'number');
      numberFocus.requestFocus();
      return;
    }

    if (!RegExp(r'^[0-9A-Z]+$').hasMatch(number)) {
      setState(() => activeError = 'number');
      numberFocus.requestFocus();
      return;
    }

    final parts = <String>[
      streetController.text.trim(),
      number,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: stateCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  hintText: 'Selecione o estado',
                  border: const OutlineInputBorder(),
                  errorText:
                      activeError == 'state' ? 'Selecione o estado.' : null,
                ),
                items: states.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text('${entry.value} (${entry.key})'),
                      ),
                    )
                    .toList(),
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
                    errorText: citiesError ??
                        (activeError == 'city'
                            ? 'Selecione a cidade.'
                            : null),
                  ),
                  items: cities
                      .map(
                        (name) => DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        ),
                      )
                      .toList(),
                  onChanged: stateCode == null || cities.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            city = value;
                            if (activeError == 'city' && value != null) {
                              activeError = null;
                            }
                          });
                        },
                ),
              const SizedBox(height: 12),
              TextField(
                controller: neighborhoodController,
                focusNode: neighborhoodFocus,
                onChanged: (_) => clearErrorWhenValid('neighborhood'),
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  border: const OutlineInputBorder(),
                  errorText: activeError == 'neighborhood'
                      ? 'Informe o bairro.'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetController,
                focusNode: streetFocus,
                onChanged: (_) => clearErrorWhenValid('street'),
                decoration: InputDecoration(
                  labelText: 'Logradouro',
                  hintText: 'Rua, avenida, travessa...',
                  border: const OutlineInputBorder(),
                  errorText:
                      activeError == 'street' ? 'Informe o logradouro.' : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                focusNode: numberFocus,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => clearErrorWhenValid('number'),
                decoration: InputDecoration(
                  labelText: 'Número',
                  hintText: 'Ex.: 20, 20A ou SN',
                  helperText: 'Use SN para endereço sem número.',
                  border: const OutlineInputBorder(),
                  errorText: activeError == 'number'
                      ? (numberController.text.trim().isEmpty
                          ? 'Informe o número ou SN.'
                          : 'Use apenas letras e números.')
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: blockController,
                decoration: const InputDecoration(
                  labelText: 'Quadra (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
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
