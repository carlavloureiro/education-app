import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_adaptativo/models/nivel_dificuldade.dart';
import 'package:quiz_adaptativo/models/questao.dart';
import 'package:quiz_adaptativo/repositories/quiz_repository.dart';
import 'package:quiz_adaptativo/screens/jogar_screen.dart';
import 'package:quiz_adaptativo/screens/questao_form_screen.dart';
import 'package:quiz_adaptativo/screens/questoes_screen.dart';
import 'package:quiz_adaptativo/widgets/sync_status_icon.dart';

import 'fakes/fake_local_datasource.dart';

/// 5 testes de widget. As telas recebem o repositório com fakes por construtor.
void main() {
  QuestaoMultiplaEscolha criarQuestao(String id, String enunciado) =>
      QuestaoMultiplaEscolha(
        id: id,
        enunciado: enunciado,
        dificuldade: NivelDificuldade.facil,
        pontosIniciais: 10,
        opcoes: ['Dart', 'Java'],
        respostaCorreta: 'Dart',
        categoria: 'Flutter',
      );

  QuizRepository criarRepo(FakeLocalDatasource local) => QuizRepository(
    local: local,
    httpClient: MockClient((r) async => http.Response('{}', 200)),
  );

  testWidgets('lista de questões renderiza os itens do banco local', (
    tester,
  ) async {
    final local = FakeLocalDatasource();
    await local.inserirQuestao(criarQuestao('Q1', 'Primeira pergunta'));
    await local.inserirQuestao(criarQuestao('Q2', 'Segunda pergunta'));

    await tester.pumpWidget(
      MaterialApp(home: QuestoesScreen(repository: criarRepo(local))),
    );
    await tester.pump(); // conclui o FutureBuilder

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Primeira pergunta'), findsOneWidget);
    expect(find.text('Segunda pergunta'), findsOneWidget);
  });

  testWidgets('formulário mostra erro nos campos obrigatórios vazios', (
    tester,
  ) async {
    final local = FakeLocalDatasource();
    await tester.pumpWidget(
      MaterialApp(home: QuestaoFormScreen(repository: criarRepo(local))),
    );

    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsNWidgets(4));
    expect(local.questoes, isEmpty);
  });

  testWidgets('formulário válido salva a questão sem mostrar erros', (
    tester,
  ) async {
    final local = FakeLocalDatasource();
    // Abre o formulário por cima de uma tela inicial, como no app.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => QuestaoFormScreen(repository: criarRepo(local)),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Qual linguagem o Flutter usa?');
    await tester.enterText(campos.at(1), 'Flutter');
    await tester.enterText(campos.at(2), 'Java; Dart; Swift');
    await tester.enterText(campos.at(3), '2');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsNothing);
    expect(local.questoes.length, 1);
    expect(local.questoes.values.first.respostaCorreta, 'Dart');
  });

  testWidgets('ícone diferencia registro pendente de sincronizado', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SyncStatusIcon(sincronizado: false),
              SyncStatusIcon(sincronizado: true),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
  });

  testWidgets('tocar numa alternativa mostra o feedback e o botão de avançar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JogarScreen(
          repository: criarRepo(FakeLocalDatasource()),
          args: JogoArgs(
            jogador: 'Ana',
            categoria: 'Flutter',
            questoes: [criarQuestao('Q1', 'Qual linguagem o Flutter usa?')],
          ),
        ),
      ),
    );

    expect(find.text('Ver resultado'), findsNothing);
    await tester.tap(find.text('Dart'));
    await tester.pump();

    expect(find.text('Correto! +10 pontos'), findsOneWidget);
    expect(find.text('Ver resultado'), findsOneWidget);
  });
}
