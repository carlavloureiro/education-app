import 'package:flutter/material.dart';

import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import 'ui_helpers.dart';

/// Botão "Baixar pacote de questões" (usado na Home e no Diagnóstico).
class BaixarPacoteButton extends StatefulWidget {
  final QuizRepository repository;
  final VoidCallback? aoConcluir;

  const BaixarPacoteButton({
    super.key,
    required this.repository,
    this.aoConcluir,
  });

  @override
  State<BaixarPacoteButton> createState() => _BaixarPacoteButtonState();
}

class _BaixarPacoteButtonState extends State<BaixarPacoteButton> {
  bool _baixando = false;

  Future<void> _baixar() async {
    setState(() => _baixando = true);
    try {
      final novas = await widget.repository.baixarPacoteDeQuestoes();
      if (mounted) {
        mostrarMensagem(
          context,
          novas == 0
              ? 'Pacote já estava atualizado.'
              : '$novas questão(ões) nova(s) baixada(s).',
        );
      }
    } on QuizException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    } finally {
      if (mounted) {
        setState(() => _baixando = false);
        widget.aoConcluir?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _baixando ? null : _baixar,
      icon: _baixando
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: const Text('Baixar pacote de questões'),
    );
  }
}
