import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../datasources/quiz_local_datasource.dart';
import '../models/partida.dart';
import '../models/questao.dart';

/// Repositório Offline-First: única porta de entrada da UI para os dados.
/// 1) Lê sempre do banco local (fonte única da verdade).
/// 2) Grava primeiro no local com sincronizado = false.
/// 3) Tenta a API; só marca sincronizado = true com status 200/201.
class QuizRepository with LogAuditoriaMixin {
  static const urlPadrao = 'https://api.quiz-adaptativo.mock/v1';
  static const _cabecalhos = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final QuizLocalDatasource _fonteLocal;
  final http.Client _http;
  final String _baseUrl;
  final Duration _tempoLimite;

  QuizRepository({
    required QuizLocalDatasource local,
    required http.Client httpClient,
    String? baseUrl,
    Duration timeout = const Duration(seconds: 5),
  }) : _fonteLocal = local,
       _http = httpClient,
       _baseUrl = baseUrl ?? urlPadrao,
       _tempoLimite = timeout;

  Uri _uri(String caminho) => Uri.parse('$_baseUrl/$caminho');

  // ---------------- Leitura (sempre local) ----------------

  Future<List<QuestaoMultiplaEscolha>> listarQuestoes() =>
      _fonteLocal.listarQuestoes();

  /// Ranking ordenado da maior para a menor pontuação.
  Future<List<Partida>> listarRanking() async =>
      (await _fonteLocal.listarPartidas())
        ..sort((a, b) => b.pontuacao.compareTo(a.pontuacao));

  Future<DateTime?> ultimaSincronizacao() =>
      _fonteLocal.lerUltimaSincronizacao();

  /// Total de registros aguardando envio (questões + partidas).
  Future<int> contarPendencias() async {
    final questoes = await _fonteLocal.listarQuestoes();
    final partidas = await _fonteLocal.listarPartidasPendentes();
    return questoes.where((q) => !q.sincronizado).length + partidas.length;
  }

  // ---------------- Escrita resiliente ----------------

  /// Cadastro ([nova] = true) ou edição de questão. Envia com PUT (idempotente).
  Future<QuestaoMultiplaEscolha> salvarQuestao(
    QuestaoMultiplaEscolha questao, {
    bool nova = true,
  }) async {
    final pendente = questao.copyWith(sincronizado: false);
    if (nova) {
      await _fonteLocal.inserirQuestao(pendente);
    } else {
      await _fonteLocal.atualizarQuestao(pendente);
    }
    return _enviarQuestao(pendente);
  }

  /// Exclui localmente e avisa a API com DELETE (melhor esforço).
  Future<void> removerQuestao(String id) async {
    await _fonteLocal.removerQuestao(id);
    await _enviar(() => _http.delete(_uri('questoes/$id')));
  }

  /// Salva a partida localmente como pendente e tenta enviar o ranking (POST).
  Future<Partida> salvarPartida(Partida partida) async {
    final pendente = partida.copyWith(sincronizado: false);
    await _fonteLocal.inserirPartida(pendente);
    return _enviarPartida(pendente);
  }

  // ---------------- Sincronização ----------------

  /// Reenvia tudo que está pendente. Lança SincronizacaoException se algo falhar.
  Future<int> sincronizarPendencias() async {
    final questoes = (await _fonteLocal.listarQuestoes())
        .where((q) => !q.sincronizado)
        .toList();
    final partidas = await _fonteLocal.listarPartidasPendentes();

    var enviados = 0;
    for (final q in questoes) {
      if ((await _enviarQuestao(q)).sincronizado) enviados++;
    }
    for (final p in partidas) {
      if ((await _enviarPartida(p)).sincronizado) enviados++;
    }

    final falhas = questoes.length + partidas.length - enviados;
    if (falhas > 0) {
      throw SincronizacaoException(
        '$falhas pendência(s) não enviada(s). Verifique a conexão.',
      );
    }
    await _fonteLocal.salvarUltimaSincronizacao(DateTime.now());
    return enviados;
  }

  /// GET do pacote de questões; grava no SQLite sem duplicar (ignora ids existentes).
  /// Retorna quantas questões novas foram gravadas.
  Future<int> baixarPacoteDeQuestoes() async {
    try {
      final resposta = await _http.get(_uri('questoes')).timeout(_tempoLimite);
      if (resposta.statusCode != 200) {
        throw SincronizacaoException(
          'Servidor respondeu ${resposta.statusCode}.',
        );
      }

      final pacote = (jsonDecode(resposta.body) as List)
          .cast<Map<String, dynamic>>();
      final existentes = {
        for (final q in await _fonteLocal.listarQuestoes()) q.id,
      };
      final novas = [
        for (final item in pacote)
          if (!existentes.contains(item['id']))
            QuestaoMultiplaEscolha.fromMap({...item, 'sincronizado': true}),
      ];

      for (final q in novas) {
        await _fonteLocal.inserirQuestao(q);
      }
      await _fonteLocal.salvarUltimaSincronizacao(DateTime.now());
      return novas.length;
    } on SocketException {
      throw SincronizacaoException('Sem conexão. Tente quando estiver online.');
    } on TimeoutException {
      throw SincronizacaoException('Tempo de resposta esgotado.');
    } on FormatException {
      throw SincronizacaoException('Resposta da API em formato inválido.');
    } on QuizException {
      rethrow; // status inválido ou questão inválida no pacote: repassa à UI
    } finally {
      registrarLog('Download do pacote de questões finalizado.');
    }
  }

  // ---------------- Auxiliares de rede ----------------

  Future<QuestaoMultiplaEscolha> _enviarQuestao(
    QuestaoMultiplaEscolha questao,
  ) async {
    final ok = await _enviar(
      () => _http.put(
        _uri('questoes/${questao.id}'),
        headers: _cabecalhos,
        body: questao.toJson(),
      ),
    );
    if (!ok) return questao;
    final confirmada = questao.copyWith(sincronizado: true);
    await _fonteLocal.atualizarQuestao(confirmada);
    return confirmada;
  }

  Future<Partida> _enviarPartida(Partida partida) async {
    final ok = await _enviar(
      () => _http.post(
        _uri('partidas'),
        headers: _cabecalhos,
        body: partida.toJson(),
      ),
    );
    if (!ok) return partida;
    final confirmada = partida.copyWith(sincronizado: true);
    await _fonteLocal.atualizarPartida(confirmada);
    return confirmada;
  }

  /// Executa a requisição com timeout. Qualquer falha de rede vira `false`
  /// (o registro continua pendente) e o usuário segue usando o app.
  Future<bool> _enviar(Future<http.Response> Function() requisicao) async {
    try {
      final resposta = await requisicao().timeout(_tempoLimite);
      return resposta.statusCode == 200 || resposta.statusCode == 201;
    } on SocketException catch (e) {
      registrarLog('Sem conexão: ${e.message}');
      return false;
    } on TimeoutException {
      registrarLog('Tempo esgotado ao falar com a API.');
      return false;
    } catch (e) {
      registrarLog('Falha inesperada de rede: $e');
      return false;
    }
  }
}
