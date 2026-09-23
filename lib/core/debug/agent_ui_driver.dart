/// Debug-only agent UI taps via the Dart VM service command bus.
///
/// Listens for `tap` / `taptext` (optional `text` query param or `tap:label`)
/// and `signout`, so course/onboarding flows can be driven when the host has
/// no Simulator GUI window for OS-level clicks.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';

/// Installs a global agent UI driver (debug builds only).
final class AgentUiDriver {
  AgentUiDriver._();

  static StreamSubscription<String>? _sub;
  static Future<void> Function()? _signOut;
  static Future<void> Function(String lessonId)? _openLesson;
  static int _pointerSeq = 100;

  /// Registers the driver. Call once from app startup.
  ///
  /// [signOut] is invoked for `signout` / `sign_out` commands.
  /// [openLesson] opens a course lesson by id (`openlesson:<id>`).
  static void install({
    Future<void> Function()? signOut,
    Future<void> Function(String lessonId)? openLesson,
  }) {
    if (!kDebugMode) return;
    _signOut = signOut;
    _openLesson = openLesson;
    unawaited(_sub?.cancel());
    _sub = AgentCommands.stream.listen(_onCommand);
  }

  static Future<void> _onCommand(String cmd) async {
    final normalized = cmd.trim().toLowerCase();
    if (normalized == 'signout' || normalized == 'sign_out') {
      await _signOut?.call();
      return;
    }
    if (normalized.startsWith('openlesson:') ||
        normalized.startsWith('open_lesson:')) {
      final id =
          cmd
              .substring(cmd.indexOf(':') + 1)
              .trim();
      if (id.isEmpty) return;
      await _openLesson?.call(id);
      debugPrint('AgentUiDriver: openLesson "$id"');
      return;
    }
    if (normalized.startsWith('type:') || normalized.startsWith('enter:')) {
      final value = cmd.substring(cmd.indexOf(':') + 1);
      await _typeText(value);
      return;
    }

    String? needle;
    if (normalized.startsWith('tap:') || normalized.startsWith('taptext:')) {
      needle = normalized.substring(normalized.indexOf(':') + 1).trim();
    }
    if (needle == null || needle.isEmpty) return;
    await _tapText(needle);
  }

  static Future<void> _typeText(String value) async {
    final binding = WidgetsBinding.instance;
    EditableTextState? focused;
    EditableTextState? fallback;

    void visit(Element element) {
      if (element is StatefulElement && element.state is EditableTextState) {
        final state = element.state as EditableTextState;
        fallback ??= state;
        if (state.widget.focusNode.hasFocus) {
          focused = state;
        }
      }
      element.visitChildren(visit);
    }

    binding.rootElement?.visitChildren(visit);
    final target = focused ?? fallback;
    if (target == null) {
      debugPrint('AgentUiDriver: no EditableText for type');
      return;
    }
    target.userUpdateTextEditingValue(
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      ),
      null,
    );
    // Notify listeners (e.g. NumericPotPriceActivity onChanged).
    target.widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    debugPrint('AgentUiDriver: typed "$value"');
  }

  static Future<void> _tapText(String needle) async {
    final binding = WidgetsBinding.instance;
    final needleLower = needle.toLowerCase();
    final candidates = <_TapCandidate>[];

    // Prefer ValueKey('best-five-Ah') when tapping "card ah".
    final cardKeyMatch = RegExp(
      r'^card\s+([2-9tjqka][shdc])$',
      caseSensitive: false,
    ).firstMatch(needleLower);
    if (cardKeyMatch != null) {
      final code = cardKeyMatch.group(1)!;
      final keyNeedle = 'best-five-$code';
      Element? keyed;
      void visitKey(Element element) {
        final key = element.widget.key;
        if (key is ValueKey<String> &&
            key.value.toLowerCase() == keyNeedle.toLowerCase()) {
          keyed = element;
          return;
        }
        element.visitChildren(visitKey);
      }

      binding.rootElement?.visitChildren(visitKey);
      final hit = keyed;
      if (hit != null) {
        final ro = hit.renderObject;
        if (ro is RenderBox && ro.hasSize && ro.attached) {
          await _pointerTap(
            ro.localToGlobal(ro.size.center(Offset.zero)),
            label: 'key:$keyNeedle',
          );
          debugPrint(
            'AgentUiDriver: pointer-tapped "$needle" -> key:$keyNeedle',
          );
          return;
        }
      }
    }

    void consider({
      required String text,
      required Element element,
      required bool fromSemantics,
    }) {
      final lower = text.toLowerCase().trim();
      if (lower.isEmpty) return;
      if (lower != needleLower && !lower.contains(needleLower)) return;
      // Avoid "continue on home" stealing a plain "continue" tap when an
      // exact Continue dock exists — handled by exact sort, but also skip
      // home-nav labels when the needle is a short CTA word.
      if (needleLower == 'continue' &&
          lower != 'continue' &&
          lower.contains('home')) {
        return;
      }
      final ro = element.renderObject;
      if (ro is! RenderBox || !ro.hasSize || !ro.attached) return;

      VoidCallback? onPressed;
      var filledStyle = false;
      element.visitAncestorElements((ancestor) {
        final w = ancestor.widget;
        if (w is ButtonStyleButton) {
          onPressed = w.onPressed;
          filledStyle = true;
          return false;
        }
        if (w is InkWell) {
          onPressed = w.onTap;
          return false;
        }
        if (w is GestureDetector) {
          onPressed = w.onTap;
          return false;
        }
        if (w is IconButton) {
          onPressed = w.onPressed;
          return false;
        }
        return true;
      });
      // Semantics(button) often wraps InkWell as a child, not an ancestor.
      if (onPressed == null) {
        element.visitChildren((child) {
          void dig(Element e) {
            if (onPressed != null) return;
            final w = e.widget;
            if (w is InkWell) {
              onPressed = w.onTap;
              return;
            }
            if (w is GestureDetector) {
              onPressed = w.onTap;
              return;
            }
            if (w is ButtonStyleButton) {
              onPressed = w.onPressed;
              filledStyle = true;
              return;
            }
            e.visitChildren(dig);
          }

          dig(child);
        });
      }
      candidates.add(
        _TapCandidate(
          text: lower,
          offset: ro.localToGlobal(ro.size.center(Offset.zero)),
          exact: lower == needleLower,
          buttonish: onPressed != null,
          filledStyle: filledStyle,
          length: lower.length,
          onPressed: onPressed,
          fromSemantics: fromSemantics,
        ),
      );
    }

    void visit(Element element) {
      final widget = element.widget;
      String? text;
      if (widget is Text) {
        text = widget.data ?? widget.textSpan?.toPlainText();
      } else if (widget is RichText) {
        text = widget.text.toPlainText();
      } else if (widget is EditableText) {
        text = widget.controller.text;
      }
      if (text != null) {
        consider(text: text, element: element, fromSemantics: false);
      }
      if (widget is Semantics) {
        final label = widget.properties.label;
        if (label != null && label.isNotEmpty) {
          consider(text: label, element: element, fromSemantics: true);
        }
      }
      element.visitChildren(visit);
    }

    binding.rootElement?.visitChildren(visit);
    if (candidates.isEmpty) {
      debugPrint('AgentUiDriver: no match for "$needle"');
      return;
    }

    candidates.sort((a, b) {
      if (a.exact != b.exact) return a.exact ? -1 : 1;
      // Prefer a live onPressed target over a disabled FilledButton.
      final aLive = a.onPressed != null;
      final bLive = b.onPressed != null;
      if (aLive != bLive) return aLive ? -1 : 1;
      if (a.filledStyle != b.filledStyle) return a.filledStyle ? -1 : 1;
      if (a.buttonish != b.buttonish) return a.buttonish ? -1 : 1;
      if (a.fromSemantics != b.fromSemantics) {
        return a.fromSemantics ? -1 : 1;
      }
      if (a.length != b.length) return a.length.compareTo(b.length);
      // Prefer lower on-screen controls (lesson Check / Continue docks).
      return b.offset.dy.compareTo(a.offset.dy);
    });

    final chosen = candidates.first;
    // Card / felt semantics: always deliver a real pointer hit so InkWell
    // gesture recognizers run (direct onTap invoke was a no-op on some
    // best-five cards after hot restart).
    final preferPointer =
        chosen.fromSemantics &&
        (needleLower.startsWith('card ') ||
            chosen.text.startsWith('card ') ||
            chosen.text.startsWith('board ') ||
            chosen.text.startsWith('your hole') ||
            chosen.text.startsWith('them'));
    if (chosen.onPressed != null && !preferPointer) {
      // Run after the current microtask so setState lands in a frame.
      final cb = chosen.onPressed!;
      final completer = Completer<void>();
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        cb();
        completer.complete();
      });
      binding.scheduleFrame();
      await completer.future;
      debugPrint(
        'AgentUiDriver: invoked onPressed for "$needle" -> "${chosen.text}"',
      );
      return;
    }

    await _pointerTap(chosen.offset, label: chosen.text);
    debugPrint(
      'AgentUiDriver: pointer-tapped "$needle" -> "${chosen.text}" at ${chosen.offset}',
    );
  }

  static Future<void> _pointerTap(Offset point, {required String label}) async {
    final binding = WidgetsBinding.instance;
    final view = binding.platformDispatcher.views.first;
    final pointer = ++_pointerSeq;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(
        pointer: pointer,
        position: point,
        kind: PointerDeviceKind.touch,
        viewId: view.viewId,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 40));
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(
        pointer: pointer,
        position: point,
        kind: PointerDeviceKind.touch,
        viewId: view.viewId,
      ),
    );
    // Allow the framework to settle selection / auto-submit.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class _TapCandidate {
  _TapCandidate({
    required this.text,
    required this.offset,
    required this.exact,
    required this.buttonish,
    required this.filledStyle,
    required this.length,
    required this.onPressed,
    this.fromSemantics = false,
  });

  final String text;
  final Offset offset;
  final bool exact;
  final bool buttonish;
  final bool filledStyle;
  final int length;
  final VoidCallback? onPressed;
  final bool fromSemantics;
}
