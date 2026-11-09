/// Níveis de dificuldade do banco de questões (AP1B).
/// AP2B: enum aprimorado com rótulo para a UI, pontuação base e parser de texto.
enum NivelDificuldade {
  facil('Fácil', 10),
  medio('Médio', 20),
  dificil('Difícil', 30);

  const NivelDificuldade(this.rotulo, this.pontosBase);

  final String rotulo;
  final int pontosBase;

  /// Converte o texto vindo do SQLite/API no enum. Nulo ou desconhecido vira médio.
  static NivelDificuldade parse(String? valor) =>
      values.firstWhere((n) => n.name == valor, orElse: () => medio);
}
