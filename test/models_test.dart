import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_adaptativo/models/nivel_dificuldade.dart';
import 'package:quiz_adaptativo/models/partida.dart';
import 'package:quiz_adaptativo/models/questao.dart';

/// 8 testes de unidade: serialização e validação dos modelos.
void main() {
  QuestaoMultiplaEscolha criarQuestao({bool sincronizado = false}) =>
      QuestaoMultiplaEscolha(
        id: 'Q1',
        enunciado: 'Qual linguagem o Flutter usa?',
        dificuldade: NivelDificuldade.dificil,
        pontosIniciais: 30,
        opcoes: ['Java', 'Dart', 'Swift'],
        respostaCorreta: 'Dart',
        categoria: 'Flutter',
        sincronizado: sincronizado,
      );

  group('Questao - serialização', () {
    test('toMap converte bool em 0/1 e grava o índice da correta', () {
      final mapa = criarQuestao(sincronizado: true).toMap();
      expect(mapa['sincronizado'], 1);
      expect(mapa['correta'], 1);
      expect(mapa['dificuldade'], 'dificil');
      expect(criarQuestao().toMap()['sincronizado'], 0);
    });

    test('fromMap(toMap) reconstrói a questão vinda do SQLite', () {
      final copia = QuestaoMultiplaEscolha.fromMap(criarQuestao().toMap());
      expect(copia.opcoes, ['Java', 'Dart', 'Swift']);
      expect(copia.respostaCorreta, 'Dart');
      expect(copia.dificuldade, NivelDificuldade.dificil);
      expect(copia.categoria, 'Flutter');
      expect(copia.sincronizado, isFalse);
    });

    test('fromMap aceita payload da API e usa pontos pela dificuldade', () {
      final q = QuestaoMultiplaEscolha.fromMap({
        'id': 'API-01',
        'enunciado': 'Pergunta da API',
        'alternativas': ['A', 'B'],
        'correta': 0,
        'dificuldade': 'facil',
        'categoria': 'Dart',
      });
      expect(q.respostaCorreta, 'A');
      expect(q.pontos, NivelDificuldade.facil.pontosBase);
    });

    test('toJson gera JSON com lista e bool nativos', () {
      final json = jsonDecode(criarQuestao(sincronizado: true).toJson());
      expect(json['alternativas'], isA<List>());
      expect(json['sincronizado'], isTrue);
    });

    test('copyWith altera apenas o estado de sincronização', () {
      final original = criarQuestao();
      final copia = original.copyWith(sincronizado: true);
      expect(copia.sincronizado, isTrue);
      expect(copia.id, original.id);
      expect(copia.pontos, original.pontos);
      expect(original.sincronizado, isFalse);
    });
  });

  group('Questao e Partida - validação', () {
    test('fromMap lança QuizException para índice de correta inválido', () {
      expect(
        () => QuestaoMultiplaEscolha.fromMap({
          'enunciado': 'Pergunta',
          'alternativas': ['A', 'B'],
          'correta': 5,
        }),
        throwsA(isA<QuizException>()),
      );
    });

    test('Partida: toJson/fromMap preservam os dados', () {
      final partida = Partida(
        id: 'P1',
        jogador: 'Ana',
        categoria: 'Dart',
        pontuacao: 40,
        acertos: 3,
        total: 4,
        data: DateTime(2026, 11, 9, 20, 30),
      );
      final copia = Partida.fromMap(jsonDecode(partida.toJson()));
      expect(copia.jogador, 'Ana');
      expect(copia.data, DateTime(2026, 11, 9, 20, 30));
      expect(copia.percentual, 75);
      expect(copia.sincronizado, isFalse);
    });

    test('Partida.fromMap lança QuizException com acertos > total', () {
      expect(
        () => Partida.fromMap({'jogador': 'Ana', 'acertos': 5, 'total': 3}),
        throwsA(isA<QuizException>()),
      );
    });
  });
}
