import '../models/nivel_dificuldade.dart';
import '../models/questao.dart';

class GerenciadorQuiz {
  final List<Questao> _questoes = [];
  int _pontuacaoAluno = 0;

  int get pontuacaoAluno => _pontuacaoAluno;

  void cadastrarQuestao(Questao questao) {
    _questoes.add(questao);
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

  /// Lógica simples: acertos somam pontos
  void processarResposta(Questao questao, String resposta) {
    final acertou = questao.responder(resposta);
    if (acertou) {
      _pontuacaoAluno += questao.pontos;
    }
  }
}