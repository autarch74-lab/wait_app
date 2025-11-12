// lib/modules/report_builder.dart

import 'rss_collector.dart';

String buildRIndexText(String timestamp, String domestic, String globalFiltered, String stockApiResults) {
  final sb = StringBuffer();
  sb.writeln('[$timestamp]');
  sb.writeln(domestic.trim());
  sb.writeln('');
  sb.writeln('글로벌 지수 요약');
  sb.writeln(globalFiltered.isEmpty ? '(데이터 없음)' : globalFiltered);
  sb.writeln('');
  sb.writeln(stockApiResults.isEmpty ? '(종목 API 결과 없음)' : stockApiResults);
  return sb.toString().trim();
}

String buildRNewsText(String timestamp, List<Article> topArticles) {
  final sb = StringBuffer();
  sb.writeln('[$timestamp]');
  for (var i = 0; i < topArticles.length; i++) {
    final a = topArticles[i];
    sb.writeln('${i + 1} | ${a.source} | ${a.title} | ${a.link}');
  }
  return sb.toString().trim();
}
