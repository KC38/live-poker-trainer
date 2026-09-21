/// Course catalog loading and lesson session providers.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// Loads the bundled public course catalog.
final courseCatalogProvider = FutureProvider<CourseCatalog>((ref) async {
  final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
  return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

/// Course Cloud Functions client.
final courseServiceProvider = Provider<CourseService>(
  (ref) => CourseService(),
);
