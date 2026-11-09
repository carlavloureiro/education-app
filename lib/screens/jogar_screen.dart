import 'package:flutter/material.dart';

import '../models/partida.dart';
import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import '../routes.dart';
import '../services/gerenciador_quiz.dart';

/// Argumentos da rota de jogo.
class JogoArgs {
  final String jogador;
  final String categoria;
  final List<QuestaoMultiplaEscolha> questoes;

  const JogoArgs({
    required this.jogador,
    required this.categoria,
    required this.questoes,
  });
}

/// Rota 6: joga o quiz (offline, com as questões do SQLite).
/// A pontuação usa o GerenciadorQuiz da AP1B.
class JogarScreen extends StatefulWidget {
  final QuizRepository repository;
  final JogoArgs args;

  const JogarScreen({super.key, required this.repository, required this.args});

  @override
  State<JogarScreen> createState() => _JogarScreenState();
}

class _JogarScreenState extends State<JogarScreen> {
  final _gerenciador = GerenciadorQuiz();
  int _indice = 0;
  int _acertos = 0;
  int? _escolhida; // alternativa tocada (null = ainda não respondeu)
  bool _salvando = false;

  List<QuestaoMultiplaEscolha> get _questoes => widget.args.questoes;
  bool get _ultima => _indice == _questoes.length - 1;

  @override
  void initState() {
    super.initState();
    _gerenciador.cadastrarEmLote(_questoes);
  }

  void _responder(int alternativa) {
    if (_escolhida != null) return; // só uma resposta por questão
    final q = _questoes[_indice];
    final acertou = _gerenciador.processarResposta(q, q.opcoes[alternativa]);
    setState(() {
      _escolhida = alternativa;
      if (acertou) _acertos++;
    });
  }

  Future<void> _avancar() async {
    if (!_ultima) {
      setState(() {
        _indice++;
        _escolhida = null;
      });
      return;
    }

    // Fim do quiz: salva localmente (pendente) e tenta enviar ao ranking.
    setState(() => _salvando = true);
    final partida = await widget.repository.salvarPartida(
      Partida(
        id: 'P-${DateTime.now().millisecondsSinceEpoch}',
        jogador: widget.args.jogador,
        categoria: widget.args.categoria,
        pontuacao: _gerenciador.pontuacaoAluno,
        acertos: _acertos,
        total: _questoes.length,
        data: DateTime.now(),
      ),
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      Rotas.resultado,
      arguments: partida,
    );
  }

  /// Verde na correta e vermelho na escolhida errada, após responder.
  Color? _corDa(int i, QuestaoMultiplaEscolha q, int? escolhida) {
    if (escolhida == null) return null;
    if (q.opcoes[i] == q.respostaCorreta) return Colors.green.shade100;
    if (i == escolhida) return Colors.red.shade100;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final q = _questoes[_indice];
    final escolhida = _escolhida;
    final acertou =
        escolhida != null && q.opcoes[escolhida] == q.respostaCorreta;

    return Scaffold(
      appBar: AppBar(
        title: Text('Questão ${_indice + 1} de ${_questoes.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            LinearProgressIndicator(value: (_indice + 1) / _questoes.length),
            Text('${q.categoria} • ${q.dificuldade.rotulo} • ${q.pontos} pts'),
            Text(q.enunciado, style: Theme.of(context).textTheme.titleLarge),
            for (var i = 0; i < q.opcoes.length; i++)
              Card(
                color: _corDa(i, q, escolhida),
                child: InkWell(
                  onTap: () => _responder(i),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(q.opcoes[i]),
                  ),
                ),
              ),
            if (escolhida != null) ...[
              Text(
                acertou
                    ? 'Correto! +${q.pontos} pontos'
                    : 'Errado! Resposta: ${q.respostaCorreta}',
                style: TextStyle(
                  color: acertou ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton(
                onPressed: _salvando ? null : _avancar,
                child: Text(_ultima ? 'Ver resultado' : 'Próxima'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
