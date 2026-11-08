import 'package:farma_aqui/features/medication/presentation/pages/home_page.dart';
import 'package:farma_aqui/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('o botão Perfil da navegação abre a página de perfil', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomePage(onLogout: () async {})),
    );

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Meu perfil'), findsOneWidget);
    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('Laudos'), findsOneWidget);
  });

  testWidgets('a aba Laudos permite iniciar o cadastro de um documento', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfilePage()),
    );

    await tester.tap(find.text('Laudos'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum laudo anexado'), findsOneWidget);
    await tester.tap(find.text('Adicionar laudo'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Selecionar arquivo'), findsOneWidget);
  });
}
