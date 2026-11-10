import 'package:quiz_adaptativo/datasources/quiz_local_datasource.dart';
import 'package:quiz_adaptativo/models/partida.dart';
import 'package:quiz_adaptativo/models/questao.dart';

/// Fonte local em memória: substitui o SQLite nos testes (sem emulador).
class FakeLocalDatasource implements QuizLocalDatasource {
  final Map<String, QuestaoMultiplaEscolha> questoes = {};
  final Map<String, Partida> partidas = {};
  DateTime? ultimaSync;

  @override
  Future<void> inserirQuestao(QuestaoMultiplaEscolha q) async =>
      questoes[q.id] = q;

  @override
  Future<List<QuestaoMultiplaEscolha>> listarQuestoes() async =>
      questoes.values.toList();

  @override
  Future<void> atualizarQuestao(QuestaoMultiplaEscolha q) async =>
      questoes[q.id] = q;

  @override
  Future<void> removerQuestao(String id) async => questoes.remove(id);

  @override
  Future<void> inserirPartida(Partida p) async => partidas[p.id] = p;

  @override
  Future<List<Partida>> listarPartidas() async => partidas.values.toList();

  @override
  Future<List<Partida>> listarPartidasPendentes() async =>
      partidas.values.where((p) => !p.sincronizado).toList();

  @override
  Future<void> atualizarPartida(Partida p) async => partidas[p.id] = p;

  @override
  Future<DateTime?> lerUltimaSincronizacao() async => ultimaSync;

  @override
  Future<void> salvarUltimaSincronizacao(DateTime data) async =>
      ultimaSync = data;
}
