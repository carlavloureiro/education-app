import 'package:flutter/material.dart';

import '../datasources/mock_api.dart';
import '../models/questao.dart';
import '../repositories/quiz_repository.dart';
import '../widgets/baixar_pacote_button.dart';
import '../widgets/ui_helpers.dart';

/// Rota 10: diagnóstico de sincronização (pendências, última sincronização,
/// "Sincronizar agora" e Switch "Simular offline").
class DiagnosticoScreen extends StatefulWidget {
  final QuizRepository repository;
  final MockApi mockApi;

  const DiagnosticoScreen({
    super.key,
    required this.repository,
    required this.mockApi,
  });

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  late Future<({int pendencias, DateTime? ultima})> _estado;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _estado = _buscarEstado();
  }

  Future<({int pendencias, DateTime? ultima})> _buscarEstado() async => (
    pendencias: await widget.repository.contarPendencias(),
    ultima: await widget.repository.ultimaSincronizacao(),
  );

  // Chaves no setState: a closure não pode retornar o Future.
  void _recarregar() => setState(() {
    _estado = _buscarEstado();
  });

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    try {
      final enviados = await widget.repository.sincronizarPendencias();
      if (mounted) {
        mostrarMensagem(context, '$enviados registro(s) sincronizado(s).');
      }
    } on SincronizacaoException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    } finally {
      if (mounted) {
        _sincronizando = false;
        _recarregar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de sincronização')),
      body: FutureBuilder(
        future: _estado,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final estado = snapshot.requireData;
          final ultima = estado.ultima;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                SwitchListTile(
                  title: const Text('Simular offline'),
                  subtitle: const Text(
                    'A API simulada passa a lançar SocketException',
                  ),
                  value: widget.mockApi.simularOffline,
                  onChanged: (valor) =>
                      setState(() => widget.mockApi.simularOffline = valor),
                ),
                ListTile(
                  leading: Icon(
                    estado.pendencias == 0 ? Icons.cloud_done : Icons.cloud_off,
                    color: estado.pendencias == 0
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text('${estado.pendencias} pendência(s) de envio'),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Última sincronização'),
                  subtitle: Text(
                    ultima == null ? 'Nunca' : formatarData(ultima),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _sincronizando ? null : _sincronizar,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar agora'),
                ),
                BaixarPacoteButton(
                  repository: widget.repository,
                  aoConcluir: _recarregar,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
