import '../models/nivel_dificuldade.dart';
import '../models/questao.dart';

class GerenciadorQuiz {
  final List<Questao> _questoes = [];
  int _pontuacaoAluno = 0;

  int get pontuacaoAluno => _pontuacaoAluno;

  void cadastrarQuestao(Questao questao) {
    _questoes.add(questao);
  }

  /// Cadastro em lote demonstrando Spread Operator (...) e Null-aware Spread (...?)
  void cadastrarEmLote(
    List<Questao> loteObrigatorio, {
    List<Questao>? loteOpcional,
  }) {
    final consolidada = [...loteObrigatorio, ...?loteOpcional];
    _questoes.addAll(consolidada);
  }

  /// Filtro funcional com .where()
  List<Questao> obterPorDificuldade(NivelDificuldade dificuldade) {
    return _questoes.where((q) => q.dificuldade == dificuldade).toList();
  }

  /// Cálculo funcional com .fold()
  int calcularPontuacaoTotalDisponivel() {
    if (_questoes.isEmpty) return 0;
    return _questoes.fold<int>(0, (soma, q) => soma + q.pontos);
  }

  /// Verificação funcional com .any()
  bool temQuestoesDificeis() {
    return _questoes.any((q) => q.dificuldade == NivelDificuldade.dificil);
  }

  /// Verificação funcional com .every()
  bool todasPossuemPontuacaoValida() {
    return _questoes.every((q) => q.pontos > 0);
  }

  /// Transformação de listas de domínio com Collection-For, Collection-If e Spread (...?)
  List<String> gerarCatalogoFormatado({
    bool incluirAvisoDificuldade = true,
    List<String>? tagsExtras,
  }) {
    return [
      // Collection-For: iteração e transformação direta na coleção de domínio
      for (final q in _questoes)
        '• [${q.id}] ${q.enunciado} (${q.dificuldade.name.toUpperCase()} - ${q.pontos} pts)',

      // Collection-If: inclusão condicional de elementos na lista resultante
      if (incluirAvisoDificuldade && temQuestoesDificeis())
        '[AVISO PEDAGÓGICO]: O simulado contém perguntas de nível difícil!',

      // Null-aware Spread (...?): mescla coleção extra se não for nula
      ...?tagsExtras,
    ];
  }

  /// Lógica simples: acertos somam pontos.
  /// AP2B: passa a retornar se acertou (a tela de jogo usa para o feedback).
  bool processarResposta(Questao questao, String resposta) {
    final acertou = questao.responder(resposta);
    if (acertou) {
      _pontuacaoAluno += questao.pontos;
    }
    return acertou;
  }

  /// Classificação de proficiência adaptativa (mesmas faixas da AP1B).
  /// AP2B: extraída do CLI para ser reutilizada pelo app e pelos testes.
  static String classificarProficiencia(double percentual) {
    if (percentual >= 70) return 'Avançado';
    if (percentual >= 40) return 'Intermediário';
    return 'Iniciante';
  }

  void sincronizarResultados({bool conexaoDisponivel = false}) {
    try {
      if (!conexaoDisponivel) {
        throw QuizException(
          'Falha de conectividade ao sincronizar resultados.',
        );
      }
      print('   -> Resultados sincronizados com o servidor.');
    } on QuizException catch (e) {
      print('   [ALERTA] $e');
      rethrow;
    }
  }
}
