import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/questao.dart';

class DatabaseHelper {
  static Database? _db;

  /// Inicializa a fábrica do SQLite para funcionar em terminal/Desktop/Docker
  static void inicializarFfi() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Retorna a instância do banco de dados (Singleton)
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _iniciarBanco();
    return _db!;
  }

  /// Cria o arquivo do banco e a tabela de questões
  static Future<Database> _iniciarBanco() async {
    inicializarFfi();
    final caminhoBanco = join(Directory.current.path, 'quiz_app.db');

    return await databaseFactory.openDatabase(
      caminhoBanco,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, versao) async {
          await db.execute('''
            CREATE TABLE questoes (
              id TEXT PRIMARY KEY,
              enunciado TEXT NOT NULL,
              dificuldade TEXT NOT NULL,
              pontos INTEGER NOT NULL,
              opcoes TEXT NOT NULL,
              respostaCorreta TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  /// Salva uma questão no SQLite
  static Future<void> inserirQuestao(QuestaoMultiplaEscolha q) async {
    final db = await database;
    await db.insert(
      'questoes',
      {
        'id': q.id,
        'enunciado': q.enunciado,
        'dificuldade': q.dificuldade.name,
        'pontos': q.pontos,
        // No SQLite salvamos a lista como texto separado por ponto e vírgula
        'opcoes': q.opcoes.join(';'),
        'respostaCorreta': q.respostaCorreta,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca todas as questões salvas no SQLite e converte para objetos Dart
  static Future<List<QuestaoMultiplaEscolha>> buscarTodasQuestoes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('questoes');

    return maps.map((map) {
      return QuestaoMultiplaEscolha.fromMap({
        'id': map['id'],
        'enunciado': map['enunciado'],
        'pontos': map['pontos'],
        'opcoes': (map['opcoes'] as String).split(';'),
        'respostaCorreta': map['respostaCorreta'],
      });
    }).toList();
  }
}