import 'package:flutter/material.dart';

import '../models/partida.dart';
import '../routes.dart';
import '../services/gerenciador_quiz.dart';
import '../widgets/sync_status_icon.dart';

/// Rota 7: resultado da partida (recebe Partida).
class ResultadoScreen extends StatelessWidget {
  final Partida partida;

  const ResultadoScreen({super.key, required this.partida});

  @override
  Widget build(BuildContext context) {
    final nivel = GerenciadorQuiz.classificarProficiencia(partida.percentual);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              '${partida.pontuacao} pontos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              '${partida.acertos} de ${partida.total} acertos '
              '(${partida.percentual.toStringAsFixed(0)}%)',
              textAlign: TextAlign.center,
            ),
            Text(
              'Proficiência: $nivel',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListTile(
              leading: SyncStatusIcon(sincronizado: partida.sincronizado),
              title: Text(
                partida.sincronizado
                    ? 'Resultado enviado ao ranking online.'
                    : 'Sem conexão: resultado salvo e será enviado depois.',
              ),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, Rotas.ranking),
              icon: const Icon(Icons.emoji_events),
              label: const Text('Ver ranking'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
