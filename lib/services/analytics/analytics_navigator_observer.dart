/// [NavigatorObserver] that logs named route transitions to Analytics.
library;

import 'package:flutter/widgets.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';

/// Logs [RouteSettings.name] on push / replace / pop when present.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  /// Creates an observer bound to [analytics].
  AnalyticsNavigatorObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _log(previousRoute);
  }

  void _log(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    // Fire-and-forget; AnalyticsService never throws to callers.
    _analytics.logScreenView(name);
  }
}
