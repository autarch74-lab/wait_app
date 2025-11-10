import 'package:flutter_test/flutter_test.dart';
import 'package:wait_app/modules/indices_collector.dart';

void main() {
  test('fetchGlobalIndicesSummary returns non-empty string', () async {
    final s = await fetchGlobalIndicesSummary();
    expect(s, isNotEmpty);
  });
}
