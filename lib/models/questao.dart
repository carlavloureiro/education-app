import 'nivel_dificuldade.dart';

mixin LogAuditoriaMixin {
  void registrarLog(String mensagem) {
    final timestamp = DateTime.now().toIso8601String();
    print('[AUDITORIA QUIZ - $timestamp]: $mensagem');
  }
}

class QuizException implements Exception {
  final String mensagem;
  QuizException(this.mensagem);

  @override
  String toString() => 'QuizException: $mensagem';
}

abstract class Questao {
  final String id;
  final String enunciado;
  final NivelDificuldade dificuldade;
  int _pontos; // Atributo privado

  Questao({
    required this.id,
    required this.enunciado,
    required this.dificuldade,
    required int pontosIniciais,
  }) : _pontos = pontosIniciais;

  int get pontos => _pontos;

  set pontos(int novoValor) {
    if (novoValor <= 0) {
      throw ArgumentError('A pontuação da questão deve ser maior que zero.');
    }
    _pontos = novoValor;
  }

  bool responder(String resposta);

  @override
  String toString() =>
      'Questao [ID: $id, Dificuldade: ${dificuldade.name}, Pontos: $_pontos]';
}

/// Classe Concreta com Herança e Mixin
class QuestaoMultiplaEscolha extends Questao with LogAuditoriaMixin {
  final List<String> opcoes;
  final String respostaCorreta;

  // 1. Construtor Padrão 
  QuestaoMultiplaEscolha({
    required super.id,
    required super.enunciado,
    required super.dificuldade,
    required super.pontosIniciais,
    required this.opcoes,
    required this.respostaCorreta,
  });

  // 2. Construtor Nomeado (para questões rápidas do tipo Verdadeiro/Falso)
  QuestaoMultiplaEscolha.verdadeiroFalso({
    required String id,
    required String enunciado,
    required String respostaCorreta,
  })  : opcoes = ['Verdadeiro', 'Falso'],
        respostaCorreta = respostaCorreta,
        super(
          id: id,
          enunciado: enunciado,
          dificuldade: NivelDificuldade.facil,
          pontosIniciais: 10,
        );

  // 3. Construtor Factory 
  factory QuestaoMultiplaEscolha.fromMap(Map<String, dynamic> map) {
    final enunciado = map['enunciado'] as String? ?? '';
    if (enunciado.trim().isEmpty) {
      throw QuizException('Não é possível criar questão sem enunciado.');
    }

    final listaOpcoes = (map['opcoes'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (listaOpcoes.isEmpty) {
      throw QuizException('A questão deve ter pelo menos uma opção.');
    }

    return QuestaoMultiplaEscolha(
      id: map['id'] as String? ?? 'SEM-ID',
      enunciado: enunciado,
      dificuldade: NivelDificuldade.medio,
      pontosIniciais: map['pontos'] as int? ?? 10,
      opcoes: listaOpcoes,
      respostaCorreta: map['respostaCorreta'] as String? ?? '',
    );
  }

  @override
  bool responder(String resposta) {
    final acertou = (resposta.trim().toLowerCase() == respostaCorreta.trim().toLowerCase());
    
    if (acertou) {
      registrarLog('Aluno acertou a questão $id (+$pontos pontos).');
    } else {
      registrarLog('Aluno errou a questão $id. Resposta informada: "$resposta".');
    }
    
    return acertou;
  }

  @override
  String toString() => '${super.toString()} - Enunciado: $enunciado';
}