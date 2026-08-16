import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import 'firebase_auth_service.dart';

/// Realtime chat for the online discussion phase.
///
/// Data layout: `rooms/{roomId}/messages/{messageId}`. Messages are appended
/// with the authenticated user's UID as the sender; clients subscribe to a
/// live stream ordered newest-first and capped to the most recent messages.
/// All timestamps are stored as UTC ISO-8601 strings.
class ChatService {
  ChatService({FirebaseFirestore? firestore, FirebaseAuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? FirebaseAuthService.instance;

  /// Swappable singleton so tests can inject fakes.
  static ChatService instance = ChatService();

  final FirebaseFirestore _firestore;
  final FirebaseAuthService _authService;

  /// Number of messages kept in the live subscription per room.
  static const int _subscriptionLimit = 200;

  CollectionReference<Map<String, dynamic>> _messagesRef(String roomId) =>
      _firestore.collection('rooms').doc(roomId).collection('messages');

  /// Appends a chat message to [roomId].
  ///
  /// The sender is always taken from the authenticated user — callers cannot
  /// spoof `player_id`. Throws when the message is empty or exceeds
  /// [ChatMessage.maxLength].
  Future<void> sendMessage({
    required String roomId,
    required String playerName,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw Exception('Message cannot be empty');
    }
    if (trimmed.length > ChatMessage.maxLength) {
      throw Exception(
        'Message cannot exceed ${ChatMessage.maxLength} characters',
      );
    }

    final uid = await _authService.requireUid();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await _messagesRef(roomId).add({
      'room_id': roomId,
      'player_id': uid,
      'player_name': playerName,
      'message': trimmed,
      'type': ChatMessage.textType,
      'created_at': nowIso,
    });
  }

  /// Live stream of the room's chat messages, oldest first.
  ///
  /// The query is ordered newest-first and limited, so the emitted list is
  /// capped to the most recent [ChatMessage]s. Cancel the subscription when
  /// the screen goes away.
  Stream<List<ChatMessage>> subscribeToMessages(String roomId) {
    return _messagesRef(roomId)
        .orderBy('created_at', descending: true)
        .limit(_subscriptionLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
              .toList()
              .reversed
              .toList(),
        );
  }

  /// Deletes all chat messages in [roomId] (host-only under the rules).
  Future<void> clearMessages(String roomId) async {
    final snapshot = await _messagesRef(roomId).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    debugPrint('Cleared ${snapshot.docs.length} chat messages in room $roomId');
  }
}
