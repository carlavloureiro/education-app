import 'package:flutter/material.dart';

import '../models/partida.dart';
import '../services/gerenciador_quiz.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/ui_helpers.dart';

/// Rota 9: detalhes de uma partida do ranking (recebe Partida).
class PartidaDetalhesScreen extends StatelessWidget {
  final Partida partida;

  const PartidaDetalhesScreen({super.key, required this.partida});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Partida de ${partida.jogador}')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Pontuação'),
            subtitle: Text('${partida.pontuacao} pontos'),
          ),
          ListTile(
            title: const Text('Acertos'),
            subtitle: Text(
              '${partida.acertos} de ${partida.total} '
              '(${partida.percentual.toStringAsFixed(0)}%)',
            ),
          ),
          ListTile(
            title: const Text('Proficiência'),
            subtitle: Text(
              GerenciadorQuiz.classificarProficiencia(partida.percentual),
            ),
          ),
          ListTile(
            title: const Text('Categoria'),
            subtitle: Text(partida.categoria),
          ),
          ListTile(
            title: const Text('Data'),
            subtitle: Text(formatarData(partida.data)),
          ),
          ListTile(
            title: const Text('Sincronização'),
            subtitle: Text(
              partida.sincronizado
                  ? 'Enviada ao servidor'
                  : 'Pendente de envio',
            ),
            trailing: SyncStatusIcon(sincronizado: partida.sincronizado),
          ),
        ],
      ),
    );
  }
}
