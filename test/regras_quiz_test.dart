import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_adaptativo/models/nivel_dificuldade.dart';
import 'package:quiz_adaptativo/models/questao.dart';
import 'package:quiz_adaptativo/services/gerenciador_quiz.dart';

/// 6 testes de unidade: regras de domínio da AP1B.
void main() {
  QuestaoMultiplaEscolha criar(String id, NivelDificuldade nivel, int pontos) =>
      QuestaoMultiplaEscolha(
        id: id,
        enunciado: 'Pergunta $id',
        dificuldade: nivel,
        pontosIniciais: pontos,
        opcoes: ['Certa', 'Errada'],
        respostaCorreta: 'Certa',
      );

  group('Regras do quiz (AP1B)', () {
    test('processarResposta soma pontos só no acerto (resposta via mixin)', () {
      final gerenciador = GerenciadorQuiz();
      final q = criar('Q1', NivelDificuldade.facil, 10);
      expect(q, isA<LogAuditoriaMixin>());
      expect(gerenciador.processarResposta(q, 'certa'), isTrue);
      expect(gerenciador.processarResposta(q, 'Errada'), isFalse);
      expect(gerenciador.pontuacaoAluno, 10);
    });

    test('filtra por dificuldade (.where) e soma pontos (.fold)', () {
      final gerenciador = GerenciadorQuiz()
        ..cadastrarEmLote(
          [criar('Q1', NivelDificuldade.facil, 10)],
          loteOpcional: [criar('Q2', NivelDificuldade.dificil, 30)],
        );
      expect(
        gerenciador.obterPorDificuldade(NivelDificuldade.dificil).length,
        1,
      );
      expect(gerenciador.calcularPontuacaoTotalDisponivel(), 40);
      expect(gerenciador.temQuestoesDificeis(), isTrue);
    });

    test('setter de pontos rejeita valor menor ou igual a zero', () {
      final q = criar('Q1', NivelDificuldade.medio, 20);
      expect(() => q.pontos = 0, throwsA(isA<ArgumentError>()));
      q.pontos = 25;
      expect(q.pontos, 25);
    });

    test('construtor nomeado verdadeiroFalso aplica os padrões', () {
      final q = QuestaoMultiplaEscolha.verdadeiroFalso(
        id: 'VF1',
        enunciado: 'Dart tem null safety.',
        respostaCorreta: 'Verdadeiro',
      );
      expect(q.opcoes, ['Verdadeiro', 'Falso']);
      expect(q.dificuldade, NivelDificuldade.facil);
      expect(q.pontos, 10);
    });

    test('classificarProficiencia respeita as faixas 40% e 70%', () {
      expect(GerenciadorQuiz.classificarProficiencia(39.9), 'Iniciante');
      expect(GerenciadorQuiz.classificarProficiencia(40), 'Intermediário');
      expect(GerenciadorQuiz.classificarProficiencia(70), 'Avançado');
    });

    test('sincronizarResultados sem conexão relança QuizException', () {
      expect(
        () => GerenciadorQuiz().sincronizarResultados(conexaoDisponivel: false),
        throwsA(isA<QuizException>()),
      );
    });
  });
}
