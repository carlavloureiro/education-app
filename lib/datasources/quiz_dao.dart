import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/partida.dart';
import '../models/questao.dart';
import 'quiz_local_datasource.dart';

/// DAO SQLite (sqflite) + SharedPreferences. Única classe do app que executa SQL.
class QuizDao implements QuizLocalDatasource {
  static const _chaveUltimaSync = 'ultima_sincronizacao';

  Database? _db;

  /// Abre o banco só na primeira chamada (??= atribui apenas se for nulo).
  Future<Database> get _database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), 'quiz_adaptativo.db');
    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, versao) async {
        await db.execute('''
          CREATE TABLE questoes (
            id TEXT PRIMARY KEY,
            enunciado TEXT NOT NULL,
            alternativas TEXT NOT NULL,
            correta INTEGER NOT NULL,
            dificuldade TEXT NOT NULL,
            categoria TEXT NOT NULL,
            pontos INTEGER NOT NULL,
            sincronizado INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE partidas (
            id TEXT PRIMARY KEY,
            jogador TEXT NOT NULL,
            categoria TEXT NOT NULL,
            pontuacao INTEGER NOT NULL,
            acertos INTEGER NOT NULL,
            total INTEGER NOT NULL,
            data TEXT NOT NULL,
            sincronizado INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // ---------------- Questões ----------------

  @override
  Future<void> inserirQuestao(QuestaoMultiplaEscolha questao) async {
    final db = await _database;
    await db.insert(
      'questoes',
      questao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<QuestaoMultiplaEscolha>> listarQuestoes() async {
    final db = await _database;
    final linhas = await db.query('questoes', orderBy: 'categoria, enunciado');
    return linhas.map(QuestaoMultiplaEscolha.fromMap).toList();
  }

  @override
  Future<void> atualizarQuestao(QuestaoMultiplaEscolha questao) async {
    final db = await _database;
    await db.update(
      'questoes',
      questao.toMap(),
      where: 'id = ?',
      whereArgs: [questao.id],
    );
  }

  @override
  Future<void> removerQuestao(String id) async {
    final db = await _database;
    await db.delete('questoes', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Partidas ----------------

  @override
  Future<void> inserirPartida(Partida partida) async {
    final db = await _database;
    await db.insert(
      'partidas',
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Partida>> listarPartidas() async {
    final db = await _database;
    final linhas = await db.query('partidas', orderBy: 'pontuacao DESC');
    return linhas.map(Partida.fromMap).toList();
  }

  @override
  Future<List<Partida>> listarPartidasPendentes() async {
    final db = await _database;
    final linhas = await db.query('partidas', where: 'sincronizado = 0');
    return linhas.map(Partida.fromMap).toList();
  }

  @override
  Future<void> atualizarPartida(Partida partida) async {
    final db = await _database;
    await db.update(
      'partidas',
      partida.toMap(),
      where: 'id = ?',
      whereArgs: [partida.id],
    );
  }

  // ---------------- Preferências ----------------

  @override
  Future<DateTime?> lerUltimaSincronizacao() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chaveUltimaSync);
    return texto == null ? null : DateTime.tryParse(texto);
  }

  @override
  Future<void> salvarUltimaSincronizacao(DateTime data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveUltimaSync, data.toIso8601String());
  }
}
