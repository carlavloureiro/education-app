import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Fonte remota SIMULADA: um MockClient (package:http/testing.dart) que faz o
/// papel da API REST. O repositório recebe [client] como um http.Client comum,
/// então o código de rede é o mesmo que seria usado com uma API real.
class MockApi {
  /// Ligado pelo Switch "Simular offline" da tela de Diagnóstico.
  bool simularOffline = false;

  late final http.Client client = MockClient(_responder);

  Future<http.Response> _responder(http.Request requisicao) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // latência
    if (simularOffline) {
      throw const SocketException('Sem conexão (offline simulado)');
    }

    final metodo = requisicao.method;
    final caminho = requisicao.url.path; // ex.: /v1/questoes/Q-1

    if (metodo == 'GET' && caminho.endsWith('/questoes')) {
      return _json(jsonEncode(questoes), 200);
    }
    if (metodo == 'POST' && caminho.endsWith('/partidas')) {
      return _json(requisicao.body, 201); // criado
    }
    if (metodo == 'PUT' && caminho.contains('/questoes/')) {
      return _json(requisicao.body, 200);
    }
    if (metodo == 'DELETE' && caminho.contains('/questoes/')) {
      return _json('{}', 200);
    }
    return _json('{"erro": "rota não encontrada"}', 404);
  }

  http.Response _json(String corpo, int status) => http.Response(
    corpo,
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  /// Pacote fixo de 10 questões devolvido pelo GET /questoes.
  static const questoes = [
    {
      'id': 'API-01',
      'enunciado': 'Qual linguagem é utilizada pelo Flutter?',
      'alternativas': ['Kotlin', 'Dart', 'Swift', 'JavaScript'],
      'correta': 1,
      'dificuldade': 'facil',
      'categoria': 'Flutter',
    },
    {
      'id': 'API-02',
      'enunciado': 'Qual widget possui estado mutável?',
      'alternativas': ['StatelessWidget', 'StatefulWidget', 'Text', 'Icon'],
      'correta': 1,
      'dificuldade': 'facil',
      'categoria': 'Flutter',
    },
    {
      'id': 'API-03',
      'enunciado': 'Qual método do State é chamado uma única vez na criação?',
      'alternativas': ['build', 'dispose', 'initState', 'setState'],
      'correta': 2,
      'dificuldade': 'medio',
      'categoria': 'Flutter',
    },
    {
      'id': 'API-04',
      'enunciado':
          'Qual operador do Dart retorna o valor da direita quando a esquerda é nula?',
      'alternativas': ['?.', '??', '!', '...'],
      'correta': 1,
      'dificuldade': 'facil',
      'categoria': 'Dart',
    },
    {
      'id': 'API-05',
      'enunciado': 'Qual palavra-chave aplica um mixin a uma classe em Dart?',
      'alternativas': ['extends', 'implements', 'with', 'mixin'],
      'correta': 2,
      'dificuldade': 'medio',
      'categoria': 'Dart',
    },
    {
      'id': 'API-06',
      'enunciado': 'Em Dart, um Future representa:',
      'alternativas': [
        'Um valor disponível no futuro',
        'Uma lista imutável',
        'Uma thread nativa',
        'Um widget',
      ],
      'correta': 0,
      'dificuldade': 'medio',
      'categoria': 'Dart',
    },
    {
      'id': 'API-07',
      'enunciado':
          'Na arquitetura Offline-First, a fonte única da verdade da UI é:',
      'alternativas': [
        'A API remota',
        'O banco de dados local',
        'A memória do widget',
        'O cache do navegador',
      ],
      'correta': 1,
      'dificuldade': 'dificil',
      'categoria': 'Computação Móvel',
    },
    {
      'id': 'API-08',
      'enunciado':
          'Qual método HTTP é idempotente e usado para substituir um recurso?',
      'alternativas': ['POST', 'PUT', 'PATCH', 'CONNECT'],
      'correta': 1,
      'dificuldade': 'dificil',
      'categoria': 'Computação Móvel',
    },
    {
      'id': 'API-09',
      'enunciado': 'Qual comando SQL remove registros de uma tabela?',
      'alternativas': ['DROP', 'DELETE', 'REMOVE', 'TRUNCATE COLUMN'],
      'correta': 1,
      'dificuldade': 'facil',
      'categoria': 'Banco de Dados',
    },
    {
      'id': 'API-10',
      'enunciado': 'No SQLite, como um valor booleano costuma ser armazenado?',
      'alternativas': ['TEXT "true"/"false"', 'INTEGER 0/1', 'BLOB', 'REAL'],
      'correta': 1,
      'dificuldade': 'dificil',
      'categoria': 'Banco de Dados',
    },
  ];
}
