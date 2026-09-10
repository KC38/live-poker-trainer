/// Debug-only agent command bus — drive the app via the Dart VM service.
///
/// Register once at startup ([install]), then invoke from the host:
/// `curl 'http://127.0.0.1:<port>/<token>/ext.poker.agent?isolateId=<id>&cmd=start'`
///
/// Commands: `start`, `fold`, `call`, `raise`, `next`, `back`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Broadcasts agent commands to interested screens / controllers.
final class AgentCommands {
  AgentCommands._();

  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Live command stream (debug builds only; empty otherwise).
  static Stream<String> get stream => _controller.stream;

  /// Registers `ext.poker.agent` with the VM service.
  static void install() {
    if (!kDebugMode) return;
    developer.registerExtension('ext.poker.agent', (method, params) async {
      final cmd = (params['cmd'] ?? '').trim().toLowerCase();
      if (cmd.isEmpty) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing cmd',
        );
      }
      _controller.add(cmd);
      return developer.ServiceExtensionResponse.result(
        jsonEncode({'ok': true, 'cmd': cmd}),
      );
    });
  }
}
