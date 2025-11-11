import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> writeRIndexFile(String content) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/r_index.txt');
  return file.writeAsString(content, flush: true);
}

Future<File> writeRNewsFile(String content) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/r_news.txt');
  return file.writeAsString(content, flush: true);
}
