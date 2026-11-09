import 'package:flutter/material.dart';

import 'datasources/mock_api.dart';
import 'models/partida.dart';
import 'models/questao.dart';
import 'repositories/quiz_repository.dart';
import 'routes.dart';
import 'screens/diagnostico_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jogar_screen.dart';
import 'screens/partida_detalhes_screen.dart';
import 'screens/questao_detalhes_screen.dart';
import 'screens/questao_form_screen.dart';
import 'screens/questoes_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/resultado_screen.dart';
import 'screens/selecao_screen.dart';

class QuizApp extends StatelessWidget {
  final QuizRepository repository;
  final MockApi mockApi;

  const QuizApp({super.key, required this.repository, required this.mockApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Adaptativo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: Rotas.home,
      onGenerateRoute: _gerarRota,
    );
  }

  /// Roteamento central. Passagem segura de argumentos: a tela só abre se o
  /// argumento tiver o tipo esperado (`when args is ...`); senão cai em "rota inválida".
  Route<dynamic> _gerarRota(RouteSettings settings) {
    final args = settings.arguments;
    final Widget tela = switch (settings.name) {
      Rotas.home => HomeScreen(repository: repository),
      Rotas.questoes => QuestoesScreen(repository: repository),
      Rotas.formQuestao => QuestaoFormScreen(
        repository: repository,
        questao: args is QuestaoMultiplaEscolha ? args : null,
      ),
      Rotas.detalhesQuestao when args is QuestaoMultiplaEscolha =>
        QuestaoDetalhesScreen(questao: args),
      Rotas.selecao => SelecaoScreen(repository: repository),
      Rotas.jogar when args is JogoArgs => JogarScreen(
        repository: repository,
        args: args,
      ),
      Rotas.resultado when args is Partida => ResultadoScreen(partida: args),
      Rotas.ranking => RankingScreen(repository: repository),
      Rotas.detalhesPartida when args is Partida => PartidaDetalhesScreen(
        partida: args,
      ),
      Rotas.diagnostico => DiagnosticoScreen(
        repository: repository,
        mockApi: mockApi,
      ),
      _ => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text('Rota inválida: ${settings.name}')),
      ),
    };
    return MaterialPageRoute(builder: (_) => tela, settings: settings);
  }
}
