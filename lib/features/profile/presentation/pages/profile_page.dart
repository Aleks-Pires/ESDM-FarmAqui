import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    const states = <String, String>{
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

    String? stateCode;
    String? city;
    var cities = <String>[];
    var loadingCities = false;
    String? citiesError;

    final neighborhoodController = TextEditingController();
    final streetController = TextEditingController();
    final numberController = TextEditingController();
    final blockController = TextEditingController();
    final complementController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Endereço'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
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
                      onChanged: (value) async {
                        if (value == null) return;

                        setDialogState(() {
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
                          final loadedCities = decoded
                              .map(
                                (item) =>
                                    (item as Map<String, dynamic>)['nome'] as String,
                              )
                              .toList();

                          if (!context.mounted) return;

                          setDialogState(() {
                            cities = loadedCities;
                            loadingCities = false;
                          });
                        } catch (_) {
                          if (!context.mounted) return;

                          setDialogState(() {
                            citiesError =
                                'Não foi possível carregar os municípios. Tente novamente.';
                            loadingCities = false;
                          });
                        }
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
                            : (value) {
                                setDialogState(() => city = value);
                              },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o bairro.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Logradouro',
                        hintText: 'Rua, avenida, travessa...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o logradouro.';
                        }
                        return null;
                      },
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

                        if (text.isEmpty) {
                          return 'Informe o número ou SN.';
                        }

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
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

                Navigator.pop(context, parts.join(', '));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    neighborhoodController.dispose();
    streetController.dispose();
    numberController.dispose();
    blockController.dispose();
    complementController.dispose();

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
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFEAF8F3),
                  child: Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: green,
                  ),
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
