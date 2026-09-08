// lib/main.dart
import 'models/nivel_dificuldade.dart';
import 'models/questao.dart';
import 'services/gerenciador_quiz.dart';
import 'services/database_helper.dart';

void main() async {
  print('====================================================');
  print('🎓 FACULDADE MULTIVIX - SISTEMAS DE INFORMAÇÃO');
  print('📱 COMPUTAÇÃO MÓVEL 2026/2 - AVALIAÇÃO PROCESSUAL 1');
  print('📚 TEMA 08: APLICATIVO DE EDUCAÇÃO E QUIZ ADAPTATIVO');
  print('====================================================\n');

  // -----------------------------------------------------------
  // 1. INSTANCIAÇÃO DAS ENTIDADES E CONSTRUTORES (Requisito 2)
  // -----------------------------------------------------------
  print('1. [SCAFFOLDING] Criando questões com os 3 tipos de construtores...');

  final gerenciador = GerenciadorQuiz();

  // (A) Construtor Padrão Gerativo com "super"
  final q1 = QuestaoMultiplaEscolha(
    id: 'Q01',
    enunciado: 'Qual a principal linguagem de programação utilizada pelo Flutter?',
    dificuldade: NivelDificuldade.facil,
    pontosIniciais: 10,
    opcoes: ['Java', 'Dart', 'Python', 'C#'],
    respostaCorreta: 'Dart',
  );

  // (B) Construtor Nomeado para Verdadeiro ou Falso
  final q2 = QuestaoMultiplaEscolha.verdadeiroFalso(
    id: 'Q02',
    enunciado: 'Dart 3 possui Sound Null Safety obrigatório.',
    respostaCorreta: 'Verdadeiro',
  );

  // (C) Construtor Factory com parsing de Map (simulação de carga externa/JSON)
  final dadosJson = {
    'id': 'Q03',
    'enunciado': 'Qual coleção em Dart armazena elementos únicos sem duplicação?',
    'pontos': 20,
    'opcoes': ['List', 'Map', 'Set'],
    'respostaCorreta': 'Set',
  };
  final q3 = QuestaoMultiplaEscolha.fromMap(dadosJson);

  // Cadastrando as questões no gerenciador via Spread Operators (... e ...?)
  final lotePrincipal = [q1, q2];
  final List<Questao>? loteComplementar = [q3];
  gerenciador.cadastrarEmLote(lotePrincipal, loteOpcional: loteComplementar);

  print('   -> 3 questões criadas e consolidadas via Spread Operators (... e ...?).\n');

  // -----------------------------------------------------------
  // PERSISTÊNCIA LOCAL RELACIONAL (SQLite via FFI)
  // -----------------------------------------------------------
  print('📦 [SQLITE] Demonstrando persistência local em banco relacional...');
  DatabaseHelper.inicializarFfi();

  // Gravando no SQLite
  await DatabaseHelper.inserirQuestao(q1);
  await DatabaseHelper.inserirQuestao(q2);
  await DatabaseHelper.inserirQuestao(q3);
  print('   -> Questões gravadas com sucesso no arquivo local "quiz_app.db"!');

  // Recuperando do SQLite
  final questoesDoBanco = await DatabaseHelper.buscarTodasQuestoes();
  print('   -> Total de questões recuperadas do SQLite: ${questoesDoBanco.length}');
  for (var q in questoesDoBanco) {
    print('      • [${q.id}] ${q.enunciado} (${q.pontos} pts)');
  }
  print('');

  // -----------------------------------------------------------
  // 2. MANIPULAÇÃO FUNCIONAL DE COLEÇÕES (Requisito 3)
  // -----------------------------------------------------------
  print('2. [COLEÇÕES & FUNCIONAL] Processando dados do banco de questões...');

  // Uso de .where() para filtrar por dificuldade
  final questoesFaceis = gerenciador.obterPorDificuldade(NivelDificuldade.facil);
  print('   -> Total de questões fáceis filtradas (.where): ${questoesFaceis.length}');

  // Uso de .fold() para cálculo acumulado de pontuação
  final pontuacaoMaxima = gerenciador.calcularPontuacaoTotalDisponivel();
  print('   -> Pontuação máxima acumulada no banco (.fold): $pontuacaoMaxima pontos');

  // Uso de .every() e .any()
  print('   -> Todas as questões têm pontuação positiva (.every): ${gerenciador.todasPossuemPontuacaoValida()}');
  print('   -> O banco possui questões de nível difícil (.any): ${gerenciador.temQuestoesDificeis()}');

  // Demonstração de Collection-For, Collection-If e Null-aware Spread (...?)
  print('\n   📋 [CATÁLOGO DE QUESTÕES - Collection-For, Collection-If & Spread]:');
  final catalogo = gerenciador.gerarCatalogoFormatado(
    incluirAvisoDificuldade: true,
    tagsExtras: [
      '🏷️ [METADADOS]: Simulado Oficial - AP1B',
      '🏷️ [MODO]: 100% Offline-First',
    ],
  );
  for (final linha in catalogo) {
    print('      $linha');
  }
  print('');

  // -----------------------------------------------------------
  // 3. FLUXO ADAPTATIVO, LOGS COM MIXIN E RESTRIÇÃO MÓVEL (Requisitos 2 e 4)
  // -----------------------------------------------------------
  print('3. [SIMULAÇÃO] Aluno respondendo ao Quiz (com logs do mixin e adaptação)...');

  // Simulação de resposta 1 (Acerto)
  print('\n   [Pergunta 1] Respondendo: "Dart"');
  gerenciador.processarResposta(q1, 'Dart');

  // Simulação de resposta 2 (Erro)
  print('\n   [Pergunta 2] Respondendo: "Falso"');
  gerenciador.processarResposta(q2, 'Falso');

  // Simulação de resposta 3 (Acerto)
  print('\n   [Pergunta 3] Respondendo: "Set"');
  gerenciador.processarResposta(q3, 'Set');

  // Simulação de restrição móvel (offline-first / persistência local em cache)
  print('\n   [RESTRIÇÃO MÓVEL]: Tentando sincronizar com servidor remoto...');
  try {
    gerenciador.sincronizarResultados(conexaoDisponivel: false);
  } on QuizException catch (e) {
    String? statusSincronizacao;
    statusSincronizacao ??=
        'Modo offline: resultados retidos localmente em cache e SQLite.';
    print('   -> $statusSincronizacao ($e)');
  }

  // -----------------------------------------------------------
  // 4. RELATÓRIO FORMATADO NO TERMINAL (Requisito 4)
  // -----------------------------------------------------------
  print('\n====================================================');
  print('📊 RELATÓRIO FINAL DE DESEMPENHO');
  print('====================================================');
  print('Pontos Obtidos: ${gerenciador.pontuacaoAluno} / $pontuacaoMaxima');
  
  final percentual = pontuacaoMaxima > 0 
      ? (gerenciador.pontuacaoAluno / pontuacaoMaxima) * 100 
      : 0.0;
  print('Taxa de Acerto: ${percentual.toStringAsFixed(1)}%');
  
  // Decisão de proficiência adaptativa baseada na pontuação
  if (percentual >= 70) {
    print('Nível de Proficiência Atingido: AVANÇADO 🚀');
  } else if (percentual >= 40) {
    print('Nível de Proficiência Atingido: INTERMEDIÁRIO 📘');
  } else {
    print('Nível de Proficiência Atingido: INICIANTE 📝');
  }
  print('====================================================\n');

  // -----------------------------------------------------------
  // 5. TRATAMENTO DE EXCEÇÕES E CASOS DE BORDA (Requisito 3)
  // -----------------------------------------------------------
  print('5. [TESTES DE BORDA] Verificando integridade das regras e exceções...');

  // Caso de Borda 1: Disparo de QuizException customizada
  try {
    print('   -> Teste 1: Tentando carregar questão com dados incompletos...');
    QuestaoMultiplaEscolha.fromMap({
      'enunciado': '', // Inválido: dispara exceção
      'opcoes': [],
    });
  } on QuizException catch (e) {
    print('   [SUCESSO] Exceção de negócio capturada com try-catch: $e');
  }

  // Caso de Borda 2: Encapsulamento com validação no setter
  try {
    print('   -> Teste 2: Tentando atribuir pontuação negativa via Setter...');
    q1.pontos = -10; // Dispara ArgumentError no setter encapsulado
  } on ArgumentError catch (e) {
    print('   [SUCESSO] Validação de encapsulamento funcionou: ${e.message}');
  } finally {
    print('\n✅ Demonstração finalizada com 100% de sucesso.');
  }
}