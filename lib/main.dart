import 'package:flutter/material.dart';

import 'app.dart';
import 'datasources/mock_api.dart';
import 'datasources/quiz_dao.dart';
import 'repositories/quiz_repository.dart';

/// Ponto de entrada do app Flutter (AP2B).
/// O CLI de demonstração da AP1B continua em bin/main.dart.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Injeção de dependências: DAO (SQLite) + API simulada -> repositório -> telas.
  final mockApi = MockApi();
  final repository = QuizRepository(
    local: QuizDao(),
    httpClient: mockApi.client,
  );

  runApp(QuizApp(repository: repository, mockApi: mockApi));
}
