/// As 10 rotas nomeadas do app.
class Rotas {
  static const home = '/'; // 1. Dashboard
  static const questoes = '/questoes'; // 2. Lista de questões
  static const formQuestao =
      '/questoes/form'; // 3. Cadastro/edição (arg opcional: Questao)
  static const detalhesQuestao =
      '/questoes/detalhes'; // 4. Detalhes (arg: Questao)
  static const selecao = '/selecao'; // 5. Categoria/dificuldade
  static const jogar = '/jogar'; // 6. Jogo (arg: JogoArgs)
  static const resultado = '/resultado'; // 7. Resultado (arg: Partida)
  static const ranking = '/ranking'; // 8. Ranking
  static const detalhesPartida =
      '/ranking/detalhes'; // 9. Detalhes (arg: Partida)
  static const diagnostico = '/diagnostico'; // 10. Diagnóstico de sincronização
}
