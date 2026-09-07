/// App lifecycle logging: one `app_sessions` row per process, heartbeats on
/// pause / resume, uncaught-error capture, and startup retention pruning.
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui' show ErrorCallback, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';

/// Version string mirrored from `pubspec.yaml` (no plugin dependency).
const String appVersion = '1.0.0';

/// Build number mirrored from `pubspec.yaml`.
const String appBuildNumber = '1';

/// Opens and maintains the current app session.
class AppSessionService with WidgetsBindingObserver {
  /// Creates the service around [dao].
  AppSessionService(
    this.dao, {
    this.heartbeat = const Duration(minutes: 1),
    this.pruneDelay = const Duration(seconds: 8),
    this.installErrorHandlers = true,
  });

  final DiagnosticsDao dao;

  /// How often `last_seen_at_ms` is refreshed while foregrounded.
  final Duration heartbeat;

  /// Delay before the first retention prune so startup stays snappy.
  final Duration pruneDelay;

  /// Whether to hook `FlutterError.onError` / `PlatformDispatcher.onError`.
  final bool installErrorHandlers;

  Timer? _heartbeat;
  Timer? _prune;
  bool _started = false;
  FlutterExceptionHandler? _previousFlutterError;
  ErrorCallback? _previousPlatformError;

  /// Session uuid for this process (also stored in `app_sessions`).
  late final String sessionUuid = _newUuid();

  /// Whether [start] has run.
  bool get isStarted => _started;

  /// Opens the session row, registers lifecycle + error hooks, schedules
  /// pruning. Safe to call once; later calls are no-ops. Never throws.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await dao.startSession(sessionUuid: sessionUuid, info: describeBuild());
    } catch (e, st) {
      debugPrint('[session] failed to open session row: $e');
      DiagnosticsLog.error('AppSessionService.start', e, st);
    }
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    if (installErrorHandlers) _hookErrors();
    _heartbeat = Timer.periodic(heartbeat, (_) => _touch());
    _prune = Timer(pruneDelay, () => unawaited(prune()));
    DiagnosticsLog.info(
      'AppSessionService',
      'session started',
      extra: {'uuid': sessionUuid, 'version': appVersion},
    );
  }

  /// Marks the session ended and removes hooks.
  Future<void> stop() async {
    if (!_started) return;
    _heartbeat?.cancel();
    _prune?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _unhookErrors();
    await _touch(ended: true);
    _started = false;
  }

  /// Runs retention pruning; returns rows deleted per table (empty on error).
  Future<Map<String, int>> prune() async {
    try {
      final deleted = await dao.prune();
      final total = deleted.values.fold<int>(0, (a, b) => a + b);
      if (total > 0) {
        DiagnosticsLog.info('AppSessionService.prune', 'pruned $total rows',
            extra: deleted);
      }
      return deleted;
    } catch (e, st) {
      DiagnosticsLog.error('AppSessionService.prune', e, st);
      return const {};
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_resume());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_touch(ended: true));
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        unawaited(_touch());
    }
  }

  Future<void> _touch({bool ended = false}) async {
    try {
      await dao.touchSession(ended: ended);
    } catch (_) {
      // Heartbeats are best-effort.
    }
  }

  Future<void> _resume() async {
    try {
      await dao.resumeSession();
    } catch (_) {}
  }

  void _hookErrors() {
    _previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      DiagnosticsLog.error(
        'FlutterError',
        details.exceptionAsString(),
        details.stack,
        {'library': details.library ?? ''},
      );
      _previousFlutterError?.call(details);
    };
    _previousPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      DiagnosticsLog.error('PlatformDispatcher', error, stack);
      return _previousPlatformError?.call(error, stack) ?? false;
    };
  }

  void _unhookErrors() {
    if (!installErrorHandlers) return;
    FlutterError.onError = _previousFlutterError;
    PlatformDispatcher.instance.onError = _previousPlatformError;
  }

  /// Platform / build facts for the session row. Never includes secrets.
  static AppSessionInfo describeBuild() {
    var platform = 'web';
    var osVersion = '';
    if (!kIsWeb) {
      try {
        platform = Platform.operatingSystem;
        osVersion = Platform.operatingSystemVersion;
      } catch (_) {
        platform = defaultTargetPlatform.name;
      }
    }
    return AppSessionInfo(
      appVersion: appVersion,
      buildNumber: appBuildNumber,
      platform: platform,
      osVersion: osVersion,
      isDebugBuild: kDebugMode,
    );
  }

  static String _newUuid() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
