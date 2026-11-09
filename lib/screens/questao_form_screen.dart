import 'package:flutter/material.dart';

import '../models/nivel_dificuldade.dart';
import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import '../widgets/ui_helpers.dart';

/// Rota 3: cadastro (questao == null) ou edição de questão, com validação.
class QuestaoFormScreen extends StatefulWidget {
  final QuizRepository repository;
  final QuestaoMultiplaEscolha? questao;

  const QuestaoFormScreen({super.key, required this.repository, this.questao});

  @override
  State<QuestaoFormScreen> createState() => _QuestaoFormScreenState();
}

class _QuestaoFormScreenState extends State<QuestaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enunciado = TextEditingController();
  final _categoria = TextEditingController();
  final _alternativas = TextEditingController();
  final _correta = TextEditingController();
  NivelDificuldade _dificuldade = NivelDificuldade.facil;

  bool get _edicao => widget.questao != null;

  @override
  void initState() {
    super.initState();
    final q = widget.questao;
    if (q != null) {
      _enunciado.text = q.enunciado;
      _categoria.text = q.categoria;
      _alternativas.text = q.opcoes.join('; ');
      _correta.text = '${q.indiceCorreta + 1}';
      _dificuldade = q.dificuldade;
    }
  }

  @override
  void dispose() {
    _enunciado.dispose();
    _categoria.dispose();
    _alternativas.dispose();
    _correta.dispose();
    super.dispose();
  }

  /// Alternativas digitadas separadas por ";" (vazias são descartadas).
  List<String> get _listaAlternativas => _alternativas.text
      .split(';')
      .map((a) => a.trim())
      .where((a) => a.isNotEmpty)
      .toList();

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validarEnunciado(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Campo obrigatório';
    if (texto.length < 10) return 'Mínimo de 10 caracteres';
    return null;
  }

  String? _validarAlternativas(String? valor) {
    if (_obrigatorio(valor) != null) return 'Campo obrigatório';
    if (_listaAlternativas.length < 2) {
      return 'Informe ao menos 2 alternativas separadas por ;';
    }
    return null;
  }

  String? _validarCorreta(String? valor) {
    if (_obrigatorio(valor) != null) return 'Campo obrigatório';
    final numero = int.tryParse(valor?.trim() ?? '');
    final total = _listaAlternativas.length;
    if (numero == null || numero < 1 || numero > total) {
      return 'Informe um número de 1 a $total';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final alternativas = _listaAlternativas;
    final indice = (int.tryParse(_correta.text.trim()) ?? 1) - 1;
    final questao = QuestaoMultiplaEscolha(
      id: widget.questao?.id ?? 'Q-${DateTime.now().millisecondsSinceEpoch}',
      enunciado: _enunciado.text.trim(),
      dificuldade: _dificuldade,
      pontosIniciais: _dificuldade.pontosBase,
      opcoes: alternativas,
      respostaCorreta: alternativas[indice],
      categoria: _categoria.text.trim(),
    );

    final salva = await widget.repository.salvarQuestao(
      questao,
      nova: !_edicao,
    );
    if (!mounted) return;
    mostrarMensagem(
      context,
      salva.sincronizado
          ? 'Questão salva e sincronizada.'
          : 'Questão salva no dispositivo (pendente de envio).',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_edicao ? 'Editar questão' : 'Nova questão')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              TextFormField(
                controller: _enunciado,
                decoration: const InputDecoration(
                  labelText: 'Enunciado',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: _validarEnunciado,
              ),
              TextFormField(
                controller: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                validator: _obrigatorio,
              ),
              TextFormField(
                controller: _alternativas,
                decoration: const InputDecoration(
                  labelText: 'Alternativas (separadas por ;)',
                  border: OutlineInputBorder(),
                ),
                validator: _validarAlternativas,
              ),
              TextFormField(
                controller: _correta,
                decoration: const InputDecoration(
                  labelText: 'Número da alternativa correta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validarCorreta,
              ),
              DropdownButtonFormField<NivelDificuldade>(
                initialValue: _dificuldade,
                decoration: const InputDecoration(
                  labelText: 'Dificuldade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final nivel in NivelDificuldade.values)
                    DropdownMenuItem(value: nivel, child: Text(nivel.rotulo)),
                ],
                onChanged: (nivel) =>
                    setState(() => _dificuldade = nivel ?? _dificuldade),
              ),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
