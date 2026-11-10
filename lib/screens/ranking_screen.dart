import 'package:flutter/material.dart';

import '../models/partida.dart';
import '../repositories/quiz_repository.dart';
import '../routes.dart';
import '../widgets/sync_status_icon.dart';

/// Rota 8: ranking local com ícone de sincronizado/pendente.
class RankingScreen extends StatefulWidget {
  final QuizRepository repository;

  const RankingScreen({super.key, required this.repository});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Partida>> _partidas;

  @override
  void initState() {
    super.initState();
    _partidas = widget.repository.listarRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: FutureBuilder(
        future: _partidas,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final partidas = snapshot.requireData;
          if (partidas.isEmpty) {
            return const Center(child: Text('Nenhuma partida jogada ainda.'));
          }

          return ListView.builder(
            itemCount: partidas.length,
            itemBuilder: (context, i) {
              final p = partidas[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}º')),
                title: Text(p.jogador),
                subtitle: Text(
                  '${p.pontuacao} pts • ${p.acertos}/${p.total} • ${p.categoria}',
                ),
                trailing: SyncStatusIcon(sincronizado: p.sincronizado),
                onTap: () => Navigator.pushNamed(
                  context,
                  Rotas.detalhesPartida,
                  arguments: p,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
