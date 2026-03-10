import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:todo_list/core/constants/firebase_constants.dart';

class UserProfileRepositoryException implements Exception {
  UserProfileRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Saves user profile fields in Firebase Realtime Database via REST.
class UserProfileRepository {
  UserProfileRepository({
    FirebaseAuth? firebaseAuth,
    String? baseUrl,
    http.Client? client,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _baseUrl = baseUrl ?? kFirebaseRealtimeDatabaseUrl,
        _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final String _baseUrl;
  final http.Client _client;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<String?> _getIdToken() async => _auth.currentUser?.getIdToken(false);

  Uri _uri(String path, String idToken) =>
      Uri.parse('$_baseUrl/$path.json?auth=$idToken');

  /// Stores a small profile object at `/users/{uid}/profile`.
  Future<void> upsertProfile({required String username, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw UserProfileRepositoryException('No user signed in');
    }
    final token = await _getIdToken();
    if (token == null || token.isEmpty) {
      throw UserProfileRepositoryException('Could not get auth token');
    }
    final uid = _uid;
    if (uid.isEmpty) {
      throw UserProfileRepositoryException('Invalid user id');
    }

    final payload = <String, dynamic>{
      'username': username,
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final res = await _client.patch(
      _uri('users/$uid/profile', token),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw UserProfileRepositoryException(
        res.body.isNotEmpty ? res.body : 'Error ${res.statusCode}',
      );
    }
  }
}

