// test/parser_json_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wait_app/modules/indices_collector.dart';

void main() {
  test('extractFromPollingJson handles datas schema', () {
    final sample = {
      'datas': [
        {'closePrice': '1000', 'compareToPreviousClosePrice': '-10', 'fluctuationsRatio': '-1.0'}
      ]
    };
    final extracted = extractFromPollingJson(sample, fallbackLabel: 'TEST');
    expect(extracted.contains('1000'), true);
    expect(extracted.contains('-10') || extracted.contains('+10'), true);
  });
}
