// lib/modules/indices_collector.dart

// lib/modules/indices_collector.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Public API for domestic indices
Future<String> fetchDomesticIndicesText({bool verbose = false}) async {
  // 간단한 샘플 구현. 실제 API 호출 로직으로 교체 가능.
  final buffer = StringBuffer();
  buffer.writeln('KOSPI: 4,013.64 (+59.88 / +1.51%)');
  buffer.writeln('KOSDAQ: 877.27 (+0.46 / +0.05%)');
  return buffer.toString().trim();
}

/// Public API for global indices
Future<String> fetchGlobalIndicesSummary({bool verbose = false}) async {
  final Map<String, Map<String, dynamic>> indices = {
    'Dow(종합)': {'url': 'https://polling.finance.naver.com/api/realtime/worldstock/index/.DJI', 'prefer': 'polling'},
    'S&P500(S&P)': {'url': 'https://polling.finance.naver.com/api/realtime/worldstock/index/.INX', 'prefer': 'polling'},
    'NASDAQ(종합)': {'url': 'https://polling.finance.naver.com/api/realtime/worldstock/index/.IXIC', 'prefer': 'polling'},
    'KOSPI': {'url': 'https://m.stock.naver.com/domestic/index/KOSPI', 'prefer': 'domestic'},
    'KOSDAQ': {'url': 'https://m.stock.naver.com/domestic/index/KOSDAQ', 'prefer': 'domestic'},
  };

  final buffer = StringBuffer();

  for (final entry in indices.entries) {
    final label = entry.key;
    final originalUrl = entry.value['url'] as String;
    final prefer = entry.value['prefer'] as String? ?? 'polling';
    bool found = false;

    if (prefer != 'html') {
      try {
        final resp = await http.get(Uri.parse(originalUrl)).timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          try {
            final dynamic doc = json.decode(resp.body);
            final extracted = extractFromPollingJson(doc, fallbackLabel: label);
            if (extracted.isNotEmpty) {
              buffer.writeln('- $extracted');
              found = true;
            }
          } catch (_) {
            // JSON 파싱 실패 -> HTML 폴백
          }
        }
      } catch (_) {
        // 요청 실패
      }
    }

    if (!found) {
      try {
        final resp2 = await http.get(Uri.parse(originalUrl)).timeout(const Duration(seconds: 8));
        if (resp2.statusCode == 200) {
          final extracted = extractFromHtmlFallback(resp2.body, label);
          buffer.writeln('- $extracted');
        } else {
          buffer.writeln('- $label: (not found)');
        }
      } catch (_) {
        buffer.writeln('- $label: (not found)');
      }
    }
  }

  return buffer.toString().trim();
}

/// Public helper for tests and reuse
String extractFromPollingJson(dynamic doc, {String fallbackLabel = ''}) {
  try {
    if (doc is Map && doc.containsKey('datas') && doc['datas'] is List && (doc['datas'] as List).isNotEmpty) {
      final Map first = (doc['datas'] as List).first;
      final closePrice = (first['closePrice'] ?? first['close'] ?? first['price'] ?? first['last'])?.toString() ?? '';
      final compareClose = (first['compareToPreviousClosePrice'] ?? first['compareToPreviousPrice'] ?? first['change'])?.toString() ?? '';
      final fluctuationsRatio = (first['fluctuationsRatio'] ?? first['changeRate'] ?? first['percent'])?.toString() ?? '';
      String changeStr = compareClose.replaceAll(',', '');
      String rateStr = fluctuationsRatio.replaceAll(',', '');
      if (rateStr.isNotEmpty && !rateStr.contains('%')) {
        rateStr = '$rateStr%';
      }
      final parts = <String>[];
      if (fallbackLabel.isNotEmpty) {
        parts.add(fallbackLabel);
      }
      if (closePrice.isNotEmpty) {
        parts.add(closePrice.replaceAll(',', ''));
      }
      if (changeStr.isNotEmpty) {
        parts.add(changeStr.startsWith('-') ? changeStr : '+$changeStr');
      }
      if (rateStr.isNotEmpty) {
        parts.add(rateStr);
      }
      return parts.join(' ');
    }
  } catch (_) {}
  final candidates = collectNumericCandidates(doc);
  if (candidates.isNotEmpty) {
    final first = candidates.values.first;
    return '$fallbackLabel $first';
  }
  return '';
}

Map<String, String> collectNumericCandidates(dynamic node) {
  final Map<String, String> found = {};
  void walk(dynamic v, [String path = '']) {
    if (v == null) {
      return;
    }
    if (v is Map) {
      v.forEach((k, val) {
        final key = k.toString().toLowerCase();
        if (val is num || (val is String && RegExp(r'^[+-]?\d{1,3}(?:,\d{3})*(?:\.\d+)?%?$').hasMatch(val.trim()))) {
          final fullKey = path.isEmpty ? key : '$path.$key';
          found[fullKey] = val.toString();
        }
        walk(val, path.isEmpty ? key : '$path.$key');
      });
    } else if (v is List) {
      for (var i = 0; i < v.length; i++) {
        walk(v[i], '$path[$i]');
      }
    } else {
      if (v is num || (v is String && RegExp(r'^[+-]?\d{1,3}(?:,\d{3})*(?:\.\d+)?%?$').hasMatch(v.toString().trim()))) {
        if (path.isNotEmpty) {
          found[path] = v.toString();
        }
      }
    }
  }
  walk(node);
  return found;
}

String extractFromHtmlFallback(String body, String label) {
  final numToken = RegExp(r'[+-]?\d{1,3}(?:,\d{3})*(?:\.\d+)?');
  final percentToken = RegExp(r'[+-]?\d+(?:\.\d+)?\s*%');
  final allNums = <String>[];
  for (final m in numToken.allMatches(body)) {
    allNums.add(m.group(0) ?? '');
  }
  final percents = <String>[];
  for (final m in percentToken.allMatches(body)) {
    percents.add(m.group(0) ?? '');
  }
  String clean(String s) => s.replaceAll(',', '').trim();
  String price = '';
  String change = '';
  String rate = '';
  if (allNums.isNotEmpty) {
    price = clean(allNums[0]);
    if (allNums.length >= 2) {
      final second = allNums[1];
      if (second.startsWith('+') || second.startsWith('-')) {
        change = clean(second);
        if (percents.isNotEmpty) {
          rate = percents.first.replaceAll(' ', '');
        }
      } else {
        if (percents.isNotEmpty) {
          rate = percents.first.replaceAll(' ', '');
        } else {
          final signed = allNums.firstWhere((t) => t.startsWith('+') || t.startsWith('-'), orElse: () => '');
          if (signed.isNotEmpty) {
            change = clean(signed);
          } else {
            change = clean(second);
          }
        }
      }
    } else {
      if (percents.isNotEmpty) {
        rate = percents.first.replaceAll(' ', '');
      }
    }
  } else {
    if (percents.isNotEmpty) {
      rate = percents.first.replaceAll(' ', '');
    }
  }
  final parts = <String>[];
  parts.add(label);
  if (price.isNotEmpty) {
    parts.add(price);
  }
  if (change.isNotEmpty) {
    parts.add(change.startsWith('-') ? change : '+$change');
  }
  if (rate.isNotEmpty) {
    parts.add(rate);
  }
  return parts.join(' ');
}
