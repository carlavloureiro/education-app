import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_adaptativo/datasources/mock_api.dart';
import 'package:quiz_adaptativo/models/partida.dart';
import 'package:quiz_adaptativo/repositories/quiz_repository.dart';

import 'fakes/fake_local_datasource.dart';

/// 6 testes de unidade: fallback Offline-First do repositório.
void main() {
  Partida criarPartida(String id, {bool sincronizado = false}) => Partida(
    id: id,
    jogador: 'Ana',
    categoria: 'Dart',
    pontuacao: 30,
    acertos: 2,
    total: 3,
    data: DateTime(2026, 11, 9),
    sincronizado: sincronizado,
  );

  QuizRepository criarRepo(
    FakeLocalDatasource local,
    MockClientHandler handler, {
    Duration timeout = const Duration(seconds: 5),
  }) => QuizRepository(
    local: local,
    httpClient: MockClient(handler),
    timeout: timeout,
  );

  group('QuizRepository - Offline-First', () {
    test('mantém a partida pendente quando a API retorna 500', () async {
      final local = FakeLocalDatasource();
      final repo = criarRepo(local, (_) async => http.Response('Erro', 500));

      final resultado = await repo.salvarPartida(criarPartida('P1'));

      expect(resultado.sincronizado, isFalse);
      expect(local.partidas['P1']?.sincronizado, isFalse);
    });

    test(
      'mantém a partida pendente quando não há rede (SocketException)',
      () async {
        final local = FakeLocalDatasource();
        final repo = criarRepo(
          local,
          (_) async => throw const SocketException('offline'),
        );

        final resultado = await repo.salvarPartida(criarPartida('P1'));

        expect(resultado.sincronizado, isFalse);
        expect(local.partidas.length, 1);
      },
    );

    test(
      'marca a partida como sincronizada quando a API retorna 201',
      () async {
        final local = FakeLocalDatasource();
        final repo = criarRepo(local, (r) async => http.Response(r.body, 201));

        final resultado = await repo.salvarPartida(criarPartida('P1'));

        expect(resultado.sincronizado, isTrue);
        expect(local.partidas['P1']?.sincronizado, isTrue);
      },
    );

    test('sincronizarPendencias envia apenas os registros pendentes', () async {
      final local = FakeLocalDatasource();
      await local.inserirPartida(criarPartida('P1'));
      await local.inserirPartida(criarPartida('P2', sincronizado: true));
      var envios = 0;
      final repo = criarRepo(local, (r) async {
        envios++;
        return http.Response(r.body, 201);
      });

      final enviados = await repo.sincronizarPendencias();

      expect(enviados, 1);
      expect(envios, 1);
      expect(local.partidas['P1']?.sincronizado, isTrue);
      expect(local.ultimaSync, isNotNull);
    });

    test('baixarPacoteDeQuestoes grava as questões sem duplicar', () async {
      final local = FakeLocalDatasource();
      final repo = criarRepo(
        local,
        (_) async => http.Response(
          jsonEncode(MockApi.questoes),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      expect(await repo.baixarPacoteDeQuestoes(), 10);
      expect(await repo.baixarPacoteDeQuestoes(), 0); // segunda vez: nada novo
      expect(local.questoes.length, 10);
      expect(local.questoes.values.every((q) => q.sincronizado), isTrue);
    });

    test('trata timeout mantendo a partida pendente', () async {
      final local = FakeLocalDatasource();
      final repo = criarRepo(local, (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('{}', 201);
      }, timeout: const Duration(milliseconds: 50));

      final resultado = await repo.salvarPartida(criarPartida('P1'));

      expect(resultado.sincronizado, isFalse);
      expect(local.partidas['P1']?.sincronizado, isFalse);
    });
  });
}
