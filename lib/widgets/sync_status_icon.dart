import 'package:flutter/material.dart';

/// Ícone de conectividade do registro: nuvem verde = sincronizado,
/// nuvem riscada laranja = pendente de envio.
class SyncStatusIcon extends StatelessWidget {
  final bool sincronizado;

  const SyncStatusIcon({super.key, required this.sincronizado});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: sincronizado ? 'Sincronizado' : 'Pendente de envio',
      child: Icon(
        sincronizado ? Icons.cloud_done : Icons.cloud_off,
        color: sincronizado ? Colors.green : Colors.orange,
      ),
    );
  }
}
