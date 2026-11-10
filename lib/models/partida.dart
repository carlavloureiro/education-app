import 'dart:convert';

import 'questao.dart';

/// AP2B: resultado de uma partida (entrada do ranking).
/// Relação lógica com as questões: a partida guarda a categoria jogada.
class Partida {
  final String id;
  final String jogador;
  final String categoria;
  final int pontuacao;
  final int acertos;
  final int total;
  final DateTime data;
  final bool sincronizado;

  const Partida({
    required this.id,
    required this.jogador,
    required this.categoria,
    required this.pontuacao,
    required this.acertos,
    required this.total,
    required this.data,
    this.sincronizado = false,
  });

  /// Percentual de acertos (0 a 100), protegido contra divisão por zero.
  double get percentual => total == 0 ? 0 : acertos * 100 / total;

  /// Cópia alterando apenas o estado de sincronização.
  Partida copyWith({bool? sincronizado}) {
    return Partida(
      id: id,
      jogador: jogador,
      categoria: categoria,
      pontuacao: pontuacao,
      acertos: acertos,
      total: total,
      data: data,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  /// Map para o SQLite (data em ISO-8601; bool vira 0/1).
  Map<String, dynamic> toMap() => {
    'id': id,
    'jogador': jogador,
    'categoria': categoria,
    'pontuacao': pontuacao,
    'acertos': acertos,
    'total': total,
    'data': data.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  /// Factory com validação: lança a exceção de domínio da AP1B para dados inválidos.
  factory Partida.fromMap(Map<String, dynamic> map) {
    final jogador = (map['jogador'] as String? ?? '').trim();
    final acertos = (map['acertos'] as num?)?.toInt() ?? 0;
    final total = (map['total'] as num?)?.toInt() ?? 0;

    if (jogador.isEmpty) {
      throw QuizException('Partida sem nome de jogador.');
    }
    if (acertos < 0 || acertos > total) {
      throw QuizException(
        'Acertos ($acertos) incompatíveis com o total ($total).',
      );
    }

    return Partida(
      id: map['id']?.toString() ?? 'SEM-ID',
      jogador: jogador,
      categoria: map['categoria'] as String? ?? 'Todas',
      pontuacao: (map['pontuacao'] as num?)?.toInt() ?? 0,
      acertos: acertos,
      total: total,
      data: DateTime.tryParse(map['data'] as String? ?? '') ?? DateTime.now(),
      sincronizado: map['sincronizado'] == 1 || map['sincronizado'] == true,
    );
  }

  /// JSON para a API (bool nativo no lugar de 0/1).
  String toJson() => jsonEncode({...toMap(), 'sincronizado': sincronizado});

  @override
  String toString() =>
      'Partida [$jogador: $pontuacao pts, $acertos/$total, sincronizado: $sincronizado]';
}
