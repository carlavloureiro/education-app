import 'package:flutter/material.dart';

import '../repositories/quiz_repository.dart';
import '../routes.dart';
import '../widgets/baixar_pacote_button.dart';

/// Rota 1: Dashboard. Lê os totais do banco local (funciona em modo avião).
class HomeScreen extends StatefulWidget {
  final QuizRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<({int questoes, int pendencias})> _resumo;

  @override
  void initState() {
    super.initState();
    _resumo = _buscarResumo();
  }

  Future<({int questoes, int pendencias})> _buscarResumo() async => (
    questoes: (await widget.repository.listarQuestoes()).length,
    pendencias: await widget.repository.contarPendencias(),
  );

  // Chaves no setState: a closure não pode retornar o Future.
  void _recarregar() => setState(() {
    _resumo = _buscarResumo();
  });

  Future<void> _abrir(String rota) async {
    await Navigator.pushNamed(context, rota);
    _recarregar(); // ao voltar, relê o banco local
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Adaptativo')),
      body: FutureBuilder(
        future: _resumo,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final resumo = snapshot.requireData;
          final semQuestoes = resumo.questoes == 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.quiz),
                    title: Text(
                      '${resumo.questoes} questão(ões) no dispositivo',
                    ),
                    subtitle: Text(
                      '${resumo.pendencias} pendência(s) de sincronização',
                    ),
                  ),
                ),
                if (semQuestoes)
                  const Text(
                    'Nenhuma questão. Baixe um pacote quando estiver online.',
                    textAlign: TextAlign.center,
                  ),
                FilledButton.icon(
                  onPressed: semQuestoes ? null : () => _abrir(Rotas.selecao),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Jogar'),
                ),
                BaixarPacoteButton(
                  repository: widget.repository,
                  aoConcluir: _recarregar,
                ),
                OutlinedButton.icon(
                  onPressed: () => _abrir(Rotas.questoes),
                  icon: const Icon(Icons.list),
                  label: const Text('Banco de questões'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _abrir(Rotas.ranking),
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Ranking'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _abrir(Rotas.diagnostico),
                  icon: const Icon(Icons.sync),
                  label: const Text('Diagnóstico de sincronização'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
