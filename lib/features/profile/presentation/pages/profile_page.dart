import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String? paymentMethod;
  final reports = <_MedicalReport>[];

  @override
  void initState() {
    super.initState();
    nameController.addListener(refreshProfileHeader);
  }

  @override
  void dispose() {
    nameController.removeListener(refreshProfileHeader);
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void refreshProfileHeader() {
    setState(() {});
  }

  String? validateName(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Informe seu nome.';
    return null;
  }

  String? validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  void saveProfile() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alterações salvas durante esta sessão.'),
      ),
    );
  }

  Future<void> editReport({_MedicalReport? report}) async {
    final updatedReport = await showDialog<_MedicalReport>(
      context: context,
      builder: (_) => _ReportEditorDialog(report: report),
    );
    if (updatedReport == null || !mounted) return;

    setState(() {
      if (report == null) {
        reports.add(updatedReport);
      } else {
        final index = reports.indexOf(report);
        if (index != -1) reports[index] = updatedReport;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A966A);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF8),
        appBar: AppBar(
          title: const Text(
            'Meu perfil',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_outline_rounded), text: 'Dados'),
              Tab(icon: Icon(Icons.description_outlined), text: 'Laudos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFEAF8F3),
                          child: Text(
                            nameController.text.isEmpty
                                ? '?'
                                : nameController.text.trim()[0].toUpperCase(),
                            style: const TextStyle(
                              color: green,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nameController.text.isEmpty
                              ? 'Complete seus dados'
                              : nameController.text,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProfileField(
                    controller: nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline_rounded,
                    validator: validateName,
                    textCapitalization: TextCapitalization.words,
                  ),
                  _ProfileField(
                    controller: emailController,
                    label: 'E-mail',
                    icon: Icons.mail_outline_rounded,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _ProfileField(
                    controller: phoneController,
                    label: 'Telefone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _ProfileField(
                    controller: addressController,
                    label: 'Endereço de entrega',
                    icon: Icons.location_on_outlined,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Forma de pagamento preferida',
                      prefixIcon: Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                      DropdownMenuItem(
                        value: 'Cartão de crédito',
                        child: Text('Cartão de crédito'),
                      ),
                      DropdownMenuItem(
                        value: 'Cartão de débito',
                        child: Text('Cartão de débito'),
                      ),
                    ],
                    onChanged: (value) => setState(() => paymentMethod = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: saveProfile,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar alterações'),
                  ),
                ],
              ),
            ),
            _buildReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    const green = Color(0xFF0A966A);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const Text(
          'Laudos e documentos',
          style: TextStyle(
            color: Color(0xFF10243B),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Anexe documentos relevantes para a solicitação de medicamentos.',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: green,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => editReport(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Adicionar laudo'),
        ),
        const SizedBox(height: 12),
        if (reports.isEmpty)
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 38,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nenhum laudo anexado',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use “Adicionar laudo” para incluir um documento.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...reports.map(
            (report) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF8F3),
                  child: Icon(Icons.description_outlined, color: green),
                ),
                title: Text(
                  report.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${_formatDate(report.date)} · ${report.fileName}'
                    '${report.description.isEmpty ? '' : '\n${report.description}'}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                isThreeLine: report.description.isNotEmpty,
                trailing: IconButton(
                  tooltip: 'Editar laudo',
                  onPressed: () => editReport(report: report),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Os arquivos ficam selecionados apenas nesta sessão e não são enviados '
          'nem armazenados em uma conta.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

final class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

final class _ReportEditorDialog extends StatefulWidget {
  const _ReportEditorDialog({this.report});

  final _MedicalReport? report;

  @override
  State<_ReportEditorDialog> createState() => _ReportEditorDialogState();
}

final class _ReportEditorDialogState extends State<_ReportEditorDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late DateTime reportDate;
  PlatformFile? selectedFile;
  bool isPickingFile = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.report?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.report?.description ?? '',
    );
    reportDate = widget.report?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> chooseFile() async {
    setState(() => isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        setState(() => selectedFile = result.files.single);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Não foi possível selecionar o arquivo: $error')),
      );
    } finally {
      if (mounted) setState(() => isPickingFile = false);
    }
  }

  Future<void> chooseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: reportDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null && mounted) {
      setState(() => reportDate = selectedDate);
    }
  }

  void saveReport() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final file = selectedFile;
    final existingReport = widget.report;
    if (file == null && existingReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anexe um arquivo ao laudo.')),
      );
      return;
    }

    Navigator.of(context).pop(
      _MedicalReport(
        title: titleController.text.trim(),
        date: reportDate,
        description: descriptionController.text.trim(),
        fileName: file?.name ?? existingReport!.fileName,
        filePath: file?.path ?? existingReport?.filePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingFileName = selectedFile?.name ?? widget.report?.fileName;
    return AlertDialog(
      title: Text(widget.report == null ? 'Adicionar laudo' : 'Editar laudo'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Informe o nome do laudo.'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Nome do laudo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data do laudo'),
                subtitle: Text(_formatDate(reportDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: chooseDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isPickingFile ? null : chooseFile,
                icon: isPickingFile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file_rounded),
                label: Text(
                  existingFileName == null
                      ? 'Selecionar arquivo'
                      : 'Trocar arquivo',
                ),
              ),
              if (existingFileName != null) ...[
                const SizedBox(height: 4),
                Text(
                  existingFileName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (widget.report == null && existingFileName == null) ...[
                const SizedBox(height: 4),
                const Text(
                  'Formatos aceitos: PDF, JPG e PNG.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: saveReport, child: const Text('Salvar')),
      ],
    );
  }
}

final class _MedicalReport {
  const _MedicalReport({
    required this.title,
    required this.date,
    required this.description,
    required this.fileName,
    required this.filePath,
  });

  final String title;
  final DateTime date;
  final String description;
  final String fileName;
  final String? filePath;
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
