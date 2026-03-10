import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:todo_list/core/constants/firebase_constants.dart';
import 'package:todo_list/data/models/task_model.dart';

class TasksRepositoryException implements Exception {
  TasksRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class TasksRepository {
  TasksRepository({
    FirebaseAuth? firebaseAuth,
    String? baseUrl,
    http.Client? client,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _baseUrl = baseUrl ?? kFirebaseRealtimeDatabaseUrl,
       _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final String _baseUrl;
  final http.Client _client;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<String?> _getIdToken() async {
    return _auth.currentUser?.getIdToken(false);
  }

  String _path([String? taskId]) {
    final segment = 'users/$_userId/tasks';
    if (taskId != null) return '$segment/$taskId.json';
    return '$segment.json';
  }

  Uri _uri(String path, [String? idToken]) {
    var url = '$_baseUrl/$path';
    if (idToken != null && idToken.isNotEmpty) {
      url += url.contains('?') ? '&' : '?';
      url += 'auth=$idToken';
    }
    return Uri.parse(url);
  }

  Future<List<TaskModel>> getTasks() async {
    final token = await _getIdToken();
    if (token == null) return [];

    final path = _path();
    final response = await _client.get(_uri(path, token));

    if (response.statusCode != 200) return [];

    final data = response.body;
    if (data == 'null' || data.isEmpty) return [];

    final decoded = jsonDecode(data) as Map<String, dynamic>?;
    if (decoded == null) return [];

    return decoded.entries.map((e) {
      final map = e.value as Map<String, dynamic>;
      return TaskModel.fromJson(e.key, map);
    }).toList();
  }

  Future<TaskModel?> addTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw TasksRepositoryException('No user signed in');
    }
    final token = await _getIdToken();
    if (token == null || token.isEmpty) {
      throw TasksRepositoryException('Could not get auth token');
    }

    final path = _path();
    final uri = _uri(path, token);
    late final http.Response response;
    try {
      response = await _client.post(
        uri,
        body: jsonEncode(task.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw TasksRepositoryException('Network error: $e');
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final name = decoded is Map ? decoded['name'] : decoded;
      final id = name is String ? name : null;
      if (id == null) {
        throw TasksRepositoryException('Invalid response from server');
      }
      return task.copyWith(id: id);
    }

    final body = response.body;
    String message;
    switch (response.statusCode) {
      case 401:
        message = 'Auth failed. Try signing out and back in.';
        break;
      case 403:
        message = 'Permission denied. Check Realtime Database rules.';
        break;
      case 404:
        message =
            'Database not found. Enable Realtime Database and check URL in firebase_constants.dart.';
        break;
      default:
        message = body.length > 80 ? 'Error ${response.statusCode}' : body;
    }
    throw TasksRepositoryException(message);
  }

  Future<bool> updateTask(TaskModel task) async {
    final token = await _getIdToken();
    if (token == null) throw TasksRepositoryException('Could not get auth token');

    final path = _path(task.id);
    final response = await _client.put(
      _uri(path, token),
      body: jsonEncode(task.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw TasksRepositoryException(
        _messageForStatus(response.statusCode, response.body),
      );
    }
    return true;
  }

  Future<bool> deleteTask(String taskId) async {
    final token = await _getIdToken();
    if (token == null) throw TasksRepositoryException('Could not get auth token');

    final path = _path(taskId);
    final response = await _client.delete(_uri(path, token));

    if (response.statusCode != 200) {
      throw TasksRepositoryException(
        _messageForStatus(response.statusCode, response.body),
      );
    }
    return true;
  }

  static String _messageForStatus(int code, String body) {
    switch (code) {
      case 401:
        return 'Auth failed. Try signing out and back in.';
      case 403:
        return 'Permission denied. Check Realtime Database rules.';
      case 404:
        return 'Database not found.';
      default:
        return body.length > 80 ? 'Error $code' : body;
    }
  }
}
