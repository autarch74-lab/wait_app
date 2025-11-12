// lib/modules/rss_collector.dart

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class Article {
  final String title;
  final String description;
  final String link;
  final DateTime? pubDate;
  final String source;
  Article(this.title, this.description, this.link, this.pubDate, this.source);
}

Future<List<Article>> fetchRssFeed(String url, String sourceName) async {
  try {
    final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) return [];
    final rss = RssFeed.parse(resp.body);
    return rss.items?.map((i) => Article(i.title ?? '', i.description ?? '', i.link ?? '', i.pubDate, sourceName)).toList() ?? [];
  } catch (_) {
    return [];
  }
}
