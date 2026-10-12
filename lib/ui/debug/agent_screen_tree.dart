/// Debug-only structured dump of what is on screen, for host agents.
///
/// Answers the `tree` agent query (`python3 tools/agent_tap.py tree`) so an
/// agent can read labels, tap targets, and SoftPulse/selection glow without
/// a screenshot round-trip. Screenshots stay for visual judgment and proof.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/debug/agent_ui_driver.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Glow a [GlowHighlight] ancestor is painting right now, if any.
///
/// Mirrors [GlowHighlight]'s own paint rule: cue rings also need the
/// enclosing [LessonSoftPulseScope] wave to be open.
String? agentGlowOf(Element element) {
  String? glow;
  element.visitAncestorElements((ancestor) {
    final w = ancestor.widget;
    if (w is! GlowHighlight) return true;
    final waveOpen =
        ancestor
            .getInheritedWidgetOfExactType<LessonSoftPulseScope>()
            ?.allowed ??
        true;
    if (w.active && (w.ignoreSoftPulse || waveOpen)) {
      glow = w.kind == GlowKind.cue ? 'gold' : 'cyan';
      return false;
    }
    return true;
  });
  return glow;
}

/// Visible labels on the current route, top-to-bottom.
///
/// Each entry: `label`, `rect` `[x, y, w, h]` in logical px, `tap`
/// (`enabled` / `disabled` / null when no control wraps it), `glow`
/// (`gold` SoftPulse cue / `cyan` selection / null), optional `key`, and
/// `semantics` when the label came from a Semantics node.
Map<String, Object?> describeAgentScreen() {
  final binding = WidgetsBinding.instance;
  final view = binding.platformDispatcher.views.first;
  final screen = Offset.zero & (view.physicalSize / view.devicePixelRatio);
  final entries = <Map<String, Object?>>[];
  final seen = <String>{};
  String? screenName;

  void add(String raw, Element element, {required bool semantics}) {
    final label = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (label.isEmpty) return;
    final route = agentRouteOf(element);
    if (route != null && !route.isCurrent) return;
    final ro = element.renderObject;
    if (ro is! RenderBox || !ro.hasSize || !ro.attached) return;
    final rect = ro.localToGlobal(Offset.zero) & ro.size;
    if (rect.isEmpty || !rect.overlaps(screen)) return;
    final box = [
      rect.left.round(),
      rect.top.round(),
      rect.width.round(),
      rect.height.round(),
    ];
    if (!seen.add('$label@$box')) return;
    final handler = agentTapHandler(element);
    String? key;
    var depth = 0;
    element.visitAncestorElements((ancestor) {
      final k = ancestor.widget.key;
      if (k is ValueKey<String>) {
        key = k.value;
        return false;
      }
      return ++depth < 4;
    });
    final ownKey = element.widget.key;
    if (ownKey is ValueKey<String>) key = ownKey.value;
    entries.add({
      'label': label,
      'rect': box,
      'tap': handler.isControl
          ? (handler.onPressed != null ? 'enabled' : 'disabled')
          : null,
      'glow': agentGlowOf(element),
      'key': ?key,
      if (semantics) 'semantics': true,
    });
  }

  void visit(Element element) {
    final widget = element.widget;
    final route = agentRouteOf(element);
    if (screenName == null &&
        (route?.isCurrent ?? false) &&
        widget.runtimeType.toString().endsWith('Screen')) {
      screenName = widget.runtimeType.toString();
    }
    if (widget is Text) {
      add(
        widget.data ?? widget.textSpan?.toPlainText() ?? '',
        element,
        semantics: false,
      );
    } else if (widget is RichText) {
      add(widget.text.toPlainText(), element, semantics: false);
    } else if (widget is EditableText) {
      add(widget.controller.text, element, semantics: false);
    } else if (widget is Semantics) {
      final label = widget.properties.label;
      if (label != null) add(label, element, semantics: true);
    }
    element.visitChildren(visit);
  }

  binding.rootElement?.visitChildren(visit);
  entries.sort((a, b) {
    final ra = a['rect']! as List<int>;
    final rb = b['rect']! as List<int>;
    final dy = ra[1].compareTo(rb[1]);
    return dy != 0 ? dy : ra[0].compareTo(rb[0]);
  });
  return {
    'screen': screenName,
    'size': [screen.width.round(), screen.height.round()],
    'gold': [
      for (final e in entries)
        if (e['glow'] == 'gold') e['label'],
    ],
    'entries': entries,
  };
}
