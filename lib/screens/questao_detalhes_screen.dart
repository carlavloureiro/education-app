import 'package:flutter/material.dart';

import '../models/questao.dart';
import '../routes.dart';
import '../widgets/sync_status_icon.dart';

/// Rota 4: detalhes de uma questão (recebe QuestaoMultiplaEscolha como argumento).
class QuestaoDetalhesScreen extends StatelessWidget {
  final QuestaoMultiplaEscolha questao;

  const QuestaoDetalhesScreen({super.key, required this.questao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da questão'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            // Troca esta tela pelo formulário de edição.
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              Rotas.formQuestao,
              arguments: questao,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            questao.enunciado,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final (i, opcao) in questao.opcoes.indexed)
            ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(opcao),
              trailing: opcao == questao.respostaCorreta
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          const Divider(),
          ListTile(
            title: const Text('Categoria'),
            subtitle: Text(questao.categoria),
          ),
          ListTile(
            title: const Text('Dificuldade'),
            subtitle: Text(
              '${questao.dificuldade.rotulo} (${questao.pontos} pts)',
            ),
          ),
          ListTile(
            title: const Text('Sincronização'),
            subtitle: Text(
              questao.sincronizado ? 'Sincronizada' : 'Pendente de envio',
            ),
            trailing: SyncStatusIcon(sincronizado: questao.sincronizado),
          ),
        ],
      ),
    );
  }
}
