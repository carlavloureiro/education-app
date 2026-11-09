import '../models/partida.dart';
import '../models/questao.dart';

/// Contrato da fonte de dados local (fonte única da verdade).
/// O repositório depende desta interface, e não do SQLite diretamente:
/// nos testes ela é trocada por um fake em memória (sem emulador).
abstract class QuizLocalDatasource {
  // Questões (CRUD)
  Future<void> inserirQuestao(QuestaoMultiplaEscolha questao);
  Future<List<QuestaoMultiplaEscolha>> listarQuestoes();
  Future<void> atualizarQuestao(QuestaoMultiplaEscolha questao);
  Future<void> removerQuestao(String id);

  // Partidas (ranking)
  Future<void> inserirPartida(Partida partida);
  Future<List<Partida>> listarPartidas();
  Future<List<Partida>> listarPartidasPendentes();
  Future<void> atualizarPartida(Partida partida);

  // Preferências: data/hora da última sincronização
  Future<DateTime?> lerUltimaSincronizacao();
  Future<void> salvarUltimaSincronizacao(DateTime data);
}
