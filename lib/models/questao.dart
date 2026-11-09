import 'dart:convert';

import 'nivel_dificuldade.dart';

/// Mixin transversal de auditoria com timestamp ISO-8601 (AP1B).
/// AP2B: também aplicado no QuizRepository para registrar eventos de rede.
mixin LogAuditoriaMixin {
  void registrarLog(String mensagem) {
    final timestamp = DateTime.now().toIso8601String();
    print('[AUDITORIA QUIZ - $timestamp]: $mensagem');
  }
}

/// Exceção de domínio para violações de regras do quiz (AP1B).
class QuizException implements Exception {
  final String mensagem;
  QuizException(this.mensagem);

  @override
  String toString() => 'QuizException: $mensagem';
}

/// AP2B: falha de rede/sincronização. Reaproveita a exceção de domínio da AP1B.
class SincronizacaoException extends QuizException {
  SincronizacaoException(super.mensagem);

  @override
  String toString() => 'SincronizacaoException: $mensagem';
}

abstract class Questao {
  final String id;
  final String enunciado;
  final NivelDificuldade dificuldade;
  final String categoria; // AP2B: agrupa questões (relação lógica com Partida)
  final bool sincronizado; // AP2B: false = pendente de envio para a API
  int _pontos; // Atributo privado

  Questao({
    required this.id,
    required this.enunciado,
    required this.dificuldade,
    required int pontosIniciais,
    this.categoria = 'Geral',
    this.sincronizado = false,
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
    super.categoria,
    super.sincronizado,
  });

  // 2. Construtor Nomeado (para questões rápidas do tipo Verdadeiro/Falso)
  // Mantém a chamada explícita super(...) da AP1B por fins didáticos.
  // ignore: use_super_parameters
  QuestaoMultiplaEscolha.verdadeiroFalso({
    required String id,
    required String enunciado,
    required this.respostaCorreta,
    String categoria = 'Geral',
  }) : opcoes = ['Verdadeiro', 'Falso'],
       super(
         id: id,
         enunciado: enunciado,
         dificuldade: NivelDificuldade.facil,
         pontosIniciais: 10,
         categoria: categoria,
       );

  // 3. Construtor Factory
  // AP2B: aceita o formato da AP1B ('opcoes'/'respostaCorreta'), o do SQLite
  // ('alternativas' como texto JSON) e o da API ('alternativas' lista + 'correta' índice).
  factory QuestaoMultiplaEscolha.fromMap(Map<String, dynamic> map) {
    final enunciado = map['enunciado'] as String? ?? '';
    if (enunciado.trim().isEmpty) {
      throw QuizException('Não é possível criar questão sem enunciado.');
    }

    final bruto = map['alternativas'] ?? map['opcoes'];
    final lista = bruto is String ? jsonDecode(bruto) as List? : bruto as List?;
    final listaOpcoes = lista?.map((e) => e.toString()).toList() ?? [];
    if (listaOpcoes.isEmpty) {
      throw QuizException('A questão deve ter pelo menos uma opção.');
    }

    final indice = (map['correta'] as num?)?.toInt();
    if (indice != null && (indice < 0 || indice >= listaOpcoes.length)) {
      throw QuizException('Índice da alternativa correta inválido: $indice');
    }

    final dificuldade = NivelDificuldade.parse(map['dificuldade'] as String?);

    return QuestaoMultiplaEscolha(
      id: map['id']?.toString() ?? 'SEM-ID',
      enunciado: enunciado,
      dificuldade: dificuldade,
      pontosIniciais:
          (map['pontos'] as num?)?.toInt() ?? dificuldade.pontosBase,
      opcoes: listaOpcoes,
      respostaCorreta: indice != null
          ? listaOpcoes[indice]
          : map['respostaCorreta'] as String? ?? '',
      categoria: map['categoria'] as String? ?? 'Geral',
      sincronizado: map['sincronizado'] == 1 || map['sincronizado'] == true,
    );
  }

  /// AP2B: posição da alternativa correta (formato usado no SQLite e na API).
  int get indiceCorreta => opcoes.indexOf(respostaCorreta);

  /// AP2B: cópia alterando apenas o estado de sincronização.
  QuestaoMultiplaEscolha copyWith({bool? sincronizado}) {
    return QuestaoMultiplaEscolha(
      id: id,
      enunciado: enunciado,
      dificuldade: dificuldade,
      pontosIniciais: pontos,
      opcoes: opcoes,
      respostaCorreta: respostaCorreta,
      categoria: categoria,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  /// AP2B: Map para o SQLite (lista vira texto JSON; bool vira 0/1).
  Map<String, dynamic> toMap() => {
    'id': id,
    'enunciado': enunciado,
    'alternativas': jsonEncode(opcoes),
    'correta': indiceCorreta,
    'dificuldade': dificuldade.name,
    'categoria': categoria,
    'pontos': pontos,
    'sincronizado': sincronizado ? 1 : 0,
  };

  /// AP2B: JSON para a API. Reaproveita toMap() com spread e troca os campos
  /// que no JSON têm tipo nativo (lista e bool).
  String toJson() => jsonEncode({
    ...toMap(),
    'alternativas': opcoes,
    'sincronizado': sincronizado,
  });

  @override
  bool responder(String resposta) {
    final acertou =
        (resposta.trim().toLowerCase() == respostaCorreta.trim().toLowerCase());

    if (acertou) {
      registrarLog('Aluno acertou a questão $id (+$pontos pontos).');
    } else {
      registrarLog(
        'Aluno errou a questão $id. Resposta informada: "$resposta".',
      );
    }

    return acertou;
  }

  @override
  String toString() => '${super.toString()} - Enunciado: $enunciado';
}
