import 'package:flutter/material.dart';

import '../models/nivel_dificuldade.dart';
import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import '../routes.dart';
import '../widgets/ui_helpers.dart';
import 'jogar_screen.dart';

/// Rota 5: nome do jogador + filtro de categoria e dificuldade.
class SelecaoScreen extends StatefulWidget {
  final QuizRepository repository;

  const SelecaoScreen({super.key, required this.repository});

  @override
  State<SelecaoScreen> createState() => _SelecaoScreenState();
}

class _SelecaoScreenState extends State<SelecaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jogador = TextEditingController();
  late Future<List<QuestaoMultiplaEscolha>> _questoes;
  String? _categoria; // null = todas
  NivelDificuldade? _dificuldade; // null = todas

  @override
  void initState() {
    super.initState();
    _questoes = widget.repository.listarQuestoes();
  }

  @override
  void dispose() {
    _jogador.dispose();
    super.dispose();
  }

  void _comecar(List<QuestaoMultiplaEscolha> questoes) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final selecionadas = questoes
        .where((q) => _categoria == null || q.categoria == _categoria)
        .where((q) => _dificuldade == null || q.dificuldade == _dificuldade)
        .toList();
    if (selecionadas.isEmpty) {
      mostrarMensagem(context, 'Nenhuma questão para esse filtro.', erro: true);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      Rotas.jogar,
      arguments: JogoArgs(
        jogador: _jogador.text.trim(),
        categoria: _categoria ?? 'Todas',
        questoes: selecionadas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova partida')),
      body: FutureBuilder(
        future: _questoes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final questoes = snapshot.requireData;
          final categorias = {for (final q in questoes) q.categoria}.toList()
            ..sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  TextFormField(
                    controller: _jogador,
                    decoration: const InputDecoration(
                      labelText: 'Nome do jogador',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  DropdownButtonFormField<String?>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      for (final c in categorias)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (c) => setState(() => _categoria = c),
                  ),
                  DropdownButtonFormField<NivelDificuldade?>(
                    initialValue: _dificuldade,
                    decoration: const InputDecoration(
                      labelText: 'Dificuldade',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      for (final n in NivelDificuldade.values)
                        DropdownMenuItem(value: n, child: Text(n.rotulo)),
                    ],
                    onChanged: (n) => setState(() => _dificuldade = n),
                  ),
                  FilledButton.icon(
                    onPressed: () => _comecar(questoes),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Começar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
