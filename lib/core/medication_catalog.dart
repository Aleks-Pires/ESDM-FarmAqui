const medicationCatalog = <String>[
  'Losartana 25 mg',
  'Losartana 50 mg',
  'Losartana 100 mg',
  'Dipirona 500 mg',
  'Dipirona 1 g',
  'Paracetamol 500 mg',
  'Paracetamol 750 mg',
  'Ibuprofeno 200 mg',
  'Ibuprofeno 400 mg',
  'Ibuprofeno 600 mg',
  'Omeprazol 20 mg',
  'Omeprazol 40 mg',
  'Pantoprazol 20 mg',
  'Pantoprazol 40 mg',
  'Metformina 500 mg',
  'Metformina 850 mg',
  'Sinvastatina 20 mg',
  'Sinvastatina 40 mg',
  'Atenolol 25 mg',
  'Atenolol 50 mg',
  'Atenolol 100 mg',
  'Hidroclorotiazida 25 mg',
  'Hidroclorotiazida 50 mg',
  'Loratadina 10 mg',
  'Cetirizina 10 mg',
  'Amlodipino 5 mg',
  'Amlodipino 10 mg',
  'Enalapril 5 mg',
  'Enalapril 10 mg',
  'Enalapril 20 mg',
  'Captopril 25 mg',
  'Captopril 50 mg',
  'Amoxicilina 500 mg',
  'Amoxicilina 875 mg',
  'Azitromicina 500 mg',
  'Prednisona 5 mg',
  'Prednisona 20 mg',
  'Sertralina 50 mg',
  'Sertralina 100 mg',
  'Fluoxetina 20 mg',
  'Insulina NPH',
  'Insulina Regular',
];

const medicationAliases = <String, List<String>>{
  'dipirona': ['metamizol', 'novalgina'],
  'paracetamol': ['acetaminofeno', 'tylenol'],
  'losartana': ['losartan'],
  'omeprazol': ['protetor gástrico'],
  'ibuprofeno': ['anti-inflamatório'],
  'loratadina': ['antialérgico'],
  'cetirizina': ['antialérgico'],
};

Iterable<String> medicationSuggestionsFor(String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return const Iterable<String>.empty();

  return medicationCatalog.where((item) {
    final lower = item.toLowerCase();
    if (lower.contains(query)) return true;

    for (final entry in medicationAliases.entries) {
      if (!lower.startsWith(entry.key)) continue;
      if (entry.value.any((alias) => alias.contains(query))) return true;
    }

    return false;
  });
}

List<String> alternativePresentations(String searched) {
  final query = searched.trim().toLowerCase();
  if (query.isEmpty) return const [];

  final base = query.split(RegExp(r'\s+\d')).first.trim();
  final alternatives = medicationCatalog
      .where((item) => item.toLowerCase().startsWith(base))
      .where((item) => item.toLowerCase() != query)
      .take(5)
      .toList();

  return alternatives;
}
