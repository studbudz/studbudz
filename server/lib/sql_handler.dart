import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';

class SqlHandler {
  late MySqlConnection _conn;
  late Map<String, String> _queries;

  SqlHandler() {
    _connect();
    _loadQueries();
  }

  Future<void> _connect({
    String host = "localhost",
    int port = 3306,
    String userName = "root",
    String password = "",
    String databaseName = "studbudz",
  }) async {
    _conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: host,
        port: port,
        user: userName,
        password: password,
        db: databaseName,
      ),
    );
  }

  Future<void> _loadQueries({String path = "lib/queries.json"}) async {
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('Queries file not found: $path');
    }

    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    _queries = Map<String, String>.from(jsonData);
  }

  Future<List<Map<String, dynamic>>> select(
    String queryKey, [
    List<dynamic>? params,
  ]) async {
    final query = _queries[queryKey];
    if (query == null) {
      throw Exception('Query "$queryKey" not found');
    }

    try {
      final results = await _conn.query(query, params ?? []);
      return results
          .map((row) => row.fields) // Convert rows to a map
          .toList();
    } catch (e) {
      print("Error during SELECT: $e");
      return [];
    }
  }

  Future<int> insert(String queryKey, [List<dynamic>? params]) async {
    final query = _queries[queryKey];
    if (query == null) {
      throw Exception('Query "$queryKey" not found');
    }

    try {
      final result = await _conn.query(query, params ?? []);
      return result.affectedRows ?? 0;
    } catch (e) {
      print("Error during INSERT: $e");
      return 0;
    }
  }

  Future<int> update(String queryKey, [List<dynamic>? params]) async {
    final query = _queries[queryKey];
    if (query == null) {
      throw Exception('Query "$queryKey" not found');
    }

    try {
      final result = await _conn.query(query, params ?? []);
      return result.affectedRows ?? 0;
    } catch (e) {
      print("Error during UPDATE: $e");
      return 0;
    }
  }

  Future<int> delete(String queryKey, [List<dynamic>? params]) async {
    final query = _queries[queryKey];
    if (query == null) {
      throw Exception('Query "$queryKey" not found');
    }

    try {
      final result = await _conn.query(query, params ?? []);
      return result.affectedRows ?? 0;
    } catch (e) {
      print("Error during DELETE: $e");
      return 0;
    }
  }

  Future<void> close() async {
    await _conn.close();
  }
}
