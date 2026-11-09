import 'package:flutter/material.dart';

import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import '../routes.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/ui_helpers.dart';

/// Rota 2: lista de questões (ListView.builder) com exclusão por gesto (Dismissible).
class QuestoesScreen extends StatefulWidget {
  final QuizRepository repository;

  const QuestoesScreen({super.key, required this.repository});

  @override
  State<QuestoesScreen> createState() => _QuestoesScreenState();
}

class _QuestoesScreenState extends State<QuestoesScreen> {
  late Future<List<QuestaoMultiplaEscolha>> _questoes;

  @override
  void initState() {
    super.initState();
    _questoes = widget.repository.listarQuestoes();
  }

  // Chaves no setState: a closure não pode retornar o Future.
  void _recarregar() => setState(() {
    _questoes = widget.repository.listarQuestoes();
  });

  Future<void> _abrir(String rota, [Object? argumento]) async {
    await Navigator.pushNamed(context, rota, arguments: argumento);
    _recarregar();
  }

  Future<void> _remover(QuestaoMultiplaEscolha questao) async {
    await widget.repository.removerQuestao(questao.id);
    if (mounted) mostrarMensagem(context, 'Questão excluída.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banco de questões')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova questão',
        onPressed: () => _abrir(Rotas.formQuestao),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _questoes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final questoes = snapshot.requireData;
          if (questoes.isEmpty) {
            return const Center(child: Text('Nenhuma questão cadastrada.'));
          }

          return ListView.builder(
            itemCount: questoes.length,
            itemBuilder: (context, i) {
              final q = questoes[i];
              return Dismissible(
                key: ValueKey(q.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  // Remove da lista na hora (UI imediata) e depois do banco.
                  setState(() => questoes.removeAt(i));
                  _remover(q);
                },
                child: ListTile(
                  title: Text(
                    q.enunciado,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${q.categoria} • ${q.dificuldade.rotulo} • ${q.pontos} pts',
                  ),
                  trailing: SyncStatusIcon(sincronizado: q.sincronizado),
                  onTap: () => _abrir(Rotas.detalhesQuestao, q),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
