import 'package:flutter/material.dart';

/// Mostra um SnackBar de sucesso (padrão) ou de erro.
void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
      ),
    );
}

/// Formata data/hora como dd/mm/aaaa hh:mm (sem pacote intl).
String formatarData(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} '
      '${dois(data.hour)}:${dois(data.minute)}';
}
