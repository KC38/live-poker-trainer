// LPT-166: every teachSpec handFamily / suitFamily the catalog authors is
// legal under teach_spec.schema.json, including the flop action classes.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog deal families are all in the teachSpec schema enum', () {
    final schema = jsonDecode(
      File('content/course/v2/schemas/teach_spec.schema.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final deal =
        (schema['properties'] as Map)['deal']['properties']
            as Map<String, dynamic>;
    final hands = {...(deal['handFamily']['enum'] as List).cast<String>()};
    final suits = {...(deal['suitFamily']['enum'] as List).cast<String>()};
    expect(hands, containsAll(['top_pair', 'air', 'weak_draw', 'strong_draw']));

    final course = jsonDecode(
      File('content/course/v2/course.json').readAsStringSync(),
    );
    final seen = <String>{};
    void walk(Object? node) {
      if (node is Map) {
        final spec = node['teachSpec'];
        if (node.containsKey('renderer') &&
            spec is Map &&
            spec['deal'] is Map) {
          final d = spec['deal'] as Map;
          for (final entry in [d, ...(d['variants'] as List? ?? const [])]) {
            final e = entry as Map;
            if (e['handFamily'] != null) {
              seen.add(e['handFamily'] as String);
              expect(hands, contains(e['handFamily']), reason: '${node['id']}');
            }
            if (e['suitFamily'] != null) {
              expect(suits, contains(e['suitFamily']), reason: '${node['id']}');
            }
          }
        }
        node.values.forEach(walk);
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(course);
    expect(seen, containsAll(['top_pair', 'air', 'weak_draw', 'strong_draw']));
  });
}
