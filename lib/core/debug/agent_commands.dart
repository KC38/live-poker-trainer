/// Debug-only agent command bus — drive the app via the Dart VM service.
///
/// Agent handbook: `docs/agents/09-agent-workflow.md`
/// and `docs/agent-ios-simulator.md`.
///
/// Register once at startup ([install]), then invoke from the host:
/// `curl 'http://127.0.0.1:<port>/<token>/ext.poker.agent?isolateId=<id>&cmd=start'`
///
/// Commands: `start`, `fold`, `call`, `check`, `raise`, `raise:45`, `allin`,
/// `next`/`dismiss` (dismisses mid-hand coach; otherwise next hand),
/// `retry`/`resume`,
/// `back` ([AgentUiDriver] pops the top route — modal sheets included),
/// `tap` / `taptext` / `tap:<label>` (UI text tap; optional `text=` param),
/// `type` / `enter` / `type:<value>` (fill focused/first EditableText),
/// `signout`.
/// Optional `amount` query param becomes `raise:<amount>`.
///
/// Read-only queries registered with [registerQuery] answer in the
/// extension response instead of the command bus: `tree` (visible labels,
/// rects, tap targets, SoftPulse/selection glow), `last` (outcome of the
/// most recent UI-driver command), `whoami` (Firebase uid for seeding).
///
/// Not for make-change ship verification — that skill only analyzes/tests,
/// then simulator-refresh after primary pull.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Answers a read-only agent query with a JSON-encodable value.
typedef AgentQuery = FutureOr<Object?> Function(Map<String, String> params);

/// Broadcasts agent commands to interested screens / controllers.
final class AgentCommands {
  AgentCommands._();

  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static final Map<String, AgentQuery> _queries = {};

  /// Registers a read-only query answered in the extension response.
  ///
  /// Queries never reach [stream]. Re-registering [name] replaces it.
  static void registerQuery(String name, AgentQuery handler) {
    if (!kDebugMode) return;
    _queries[name.toLowerCase()] = handler;
  }

  /// Runs a registered query the way the VM extension would.
  @visibleForTesting
  static Future<Object?> debugQuery(
    String name, [
    Map<String, String> params = const {},
  ]) async {
    final handler = _queries[name.toLowerCase()];
    if (handler == null) throw StateError('No agent query "$name"');
    return handler(params);
  }

  /// Live command stream (debug builds only; empty otherwise).
  static Stream<String> get stream => _controller.stream;

  /// Pushes [cmd] onto the command bus.
  ///
  /// Production commands arrive through the VM service extension. Tests use
  /// this so the UI driver can run without a VM service connection.
  @visibleForTesting
  static void debugEmit(String cmd) {
    _controller.add(cmd);
  }

  /// Registers `ext.poker.agent` with the VM service.
  static void install() {
    if (!kDebugMode) return;
    developer.registerExtension('ext.poker.agent', (method, params) async {
      var cmd = (params['cmd'] ?? '').trim().toLowerCase();
      if (cmd.isEmpty) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing cmd',
        );
      }
      final query = _queries[cmd];
      if (query != null) {
        try {
          final result = await query(params);
          return developer.ServiceExtensionResponse.result(
            jsonEncode({'ok': true, 'cmd': cmd, 'result': result}),
          );
        } catch (e) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.extensionError,
            'Query $cmd failed: $e',
          );
        }
      }
      final amountRaw = (params['amount'] ?? '').trim();
      if (amountRaw.isNotEmpty &&
          (cmd == 'raise' ||
              cmd == 'bet' ||
              cmd == 'allin' ||
              cmd == 'all_in')) {
        cmd = '$cmd:$amountRaw';
      }
      // Prefer explicit label params for UI taps (text= / label=).
      final textRaw = (params['text'] ?? params['label'] ?? '').trim();
      if (textRaw.isNotEmpty &&
          (cmd == 'tap' ||
              cmd == 'taptext' ||
              cmd.startsWith('tap:') ||
              cmd.startsWith('taptext:'))) {
        cmd = 'tap:${textRaw.toLowerCase()}';
      }
      if (textRaw.isNotEmpty &&
          (cmd == 'openlesson' ||
              cmd == 'open_lesson' ||
              cmd.startsWith('openlesson:') ||
              cmd.startsWith('open_lesson:'))) {
        cmd = 'openlesson:$textRaw';
      }
      if (textRaw.isNotEmpty &&
          (cmd == 'type' ||
              cmd == 'enter' ||
              cmd.startsWith('type:') ||
              cmd.startsWith('enter:'))) {
        cmd = 'type:$textRaw';
      }
      _controller.add(cmd);
      return developer.ServiceExtensionResponse.result(
        jsonEncode({'ok': true, 'cmd': cmd}),
      );
    });
  }
}
