/// Firestore document shape for the shared `scenarios/{contentHash}` pool.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// One row in the global scenario pool.
@immutable
class ScenarioPoolDoc {
  /// Creates a pool document model.
  const ScenarioPoolDoc({
    required this.contentHash,
    required this.payload,
    required this.source,
    required this.modelId,
    required this.generatedAt,
    required this.timesServed,
    this.lastServedAt,
    this.payloadVersion = ScenarioPoolDoc.currentPayloadVersion,
  });

  /// JSON shape version written into `payloadVersion`.
  static const int currentPayloadVersion = 1;

  /// Document id — SHA-256 of setup fields (same as [ScenarioModel.contentHash]).
  final String contentHash;

  /// Raw scenario JSON (Gemini / grader fields).
  final Map<String, dynamic> payload;

  /// Generator label, e.g. `gemini` or `offline`.
  final String source;

  /// Model id that produced [payload], when known.
  final String modelId;

  final DateTime generatedAt;
  final int timesServed;
  final DateTime? lastServedAt;
  final int payloadVersion;

  /// Parses a Firestore snapshot into a pool doc, or null if malformed.
  static ScenarioPoolDoc? fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return fromMap(snap.id, data);
  }

  /// Parses a map with [contentHash] as the document id.
  static ScenarioPoolDoc? fromMap(String contentHash, Map<String, dynamic> data) {
    final rawPayload = data['payload'];
    if (rawPayload is! Map) return null;
    final payload = Map<String, dynamic>.from(rawPayload);
    return ScenarioPoolDoc(
      contentHash: contentHash,
      payload: payload,
      source: '${data['source'] ?? 'gemini'}',
      modelId: '${data['modelId'] ?? ''}',
      generatedAt: _asDateTime(data['generatedAt']) ?? DateTime.now().toUtc(),
      timesServed: _asInt(data['timesServed'], 0),
      lastServedAt: _asDateTime(data['lastServedAt']),
      payloadVersion: _asInt(
        data['payloadVersion'],
        currentPayloadVersion,
      ),
    );
  }

  /// Firestore fields for create (Functions / Admin). Clients rarely write this.
  Map<String, dynamic> toFirestoreMap({bool includeServerTimestamps = false}) {
    return {
      'payload': payload,
      'source': source,
      'modelId': modelId,
      'generatedAt': includeServerTimestamps
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(generatedAt.toUtc()),
      'timesServed': timesServed,
      if (lastServedAt != null)
        'lastServedAt': Timestamp.fromDate(lastServedAt!.toUtc()),
      'payloadVersion': payloadVersion,
    };
  }

  /// Builds a [ScenarioModel] from [payload] (recomputes content hash).
  ScenarioModel toScenarioModel() => ScenarioModel.fromGeminiJson(payload);

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return null;
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
