// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modules/indices_collector.dart';
import 'modules/report_builder.dart';
import 'modules/file_generator.dart';
import 'app.dart';

void main() {
  runApp(createApp(const HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _log = '';
  bool _running = false;
  bool _copied = false;

  Future<void> _runIndicesFlow() async {
    if (_running) return;
    setState(() {
      _running = true;
      _copied = false;
      _log = '';
    });

    try {
      final now = DateTime.now();
      final timeLine = '현재시각: ${now.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first}';
      setState(() { _log += '(가) $timeLine\n\n'; });

      String domestic = '';
      try {
        domestic = await fetchDomesticIndicesText(verbose: false);
      } catch (e) {
        domestic = 'ERROR fetching domestic indices: $e';
      }

      String global = '';
      try {
        global = await fetchGlobalIndicesSummary(verbose: false);
      } catch (e) {
        global = 'ERROR fetching global indices: $e';
      }

      final domesticNames = <String>{};
      for (final line in domestic.split('\n')) {
        final t = line.trim();
        if (t.isEmpty) {
          continue;
        }
        final idxColon = t.indexOf(':');
        String name;
        if (idxColon != -1) {
          name = t.substring(0, idxColon).trim();
        } else {
          final parts = t.split(RegExp(r'\s+'));
          name = parts.isNotEmpty ? parts[0] : t;
        }
        domesticNames.add(name.toUpperCase());
      }

      final filteredGlobalLines = <String>[];
      for (final line in global.split('\n')) {
        final t = line.trim();
        if (t.isEmpty) {
          continue;
        }
        var skip = false;
        for (final dn in domesticNames) {
          if (t.toUpperCase().startsWith(dn) || t.toUpperCase().contains(dn)) {
            skip = true;
            break;
          }
        }
        if (!skip) {
          filteredGlobalLines.add(t);
        }
      }
      final filteredGlobal = filteredGlobalLines.join('\n');

      final rIndexText = buildRIndexText(timeLine, domestic, filteredGlobal, '');
      await writeRIndexFile(rIndexText);

      setState(() {
        _log += '(다) 지수 현황\n';
        _log += '$domestic\n\n';
        _log += '글로벌 지수 요약\n';
        _log += '${filteredGlobal.isEmpty ? "(데이터 없음)" : filteredGlobal}\n\n';
      });
    } finally {
      setState(() { _running = false; });
      if (_log.isNotEmpty) {
        const int clipboardMax = 20000;
        final String toCopy = _log.length > clipboardMax ? '${_log.substring(0, clipboardMax)}\n...[truncated]' : _log;
        try {
          await Clipboard.setData(ClipboardData(text: toCopy));
          setState(() { _copied = true; });
          if (mounted) {
            final message = _log.length > clipboardMax ? '클립보드 복사완료 (요약)' : '클립보드 복사완료';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          }
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('클립보드 복사 실패: $e')));
        }
      }
    }
  }

  // Issue flow and other UI omitted for brevity; keep same pattern as _runIndicesFlow

  void clearLog() {
    setState(() {
      _log = '';
      _copied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wait')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(onPressed: _running ? null : _runIndicesFlow, child: const Text('Kospi')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _running ? null : () async {}, child: const Text('Issue')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _running ? null : () async {}, child: const Text('Category')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: _log.isEmpty ? null : clearLog, child: const Text('Clear')),
                const SizedBox(width: 12),
                if (_running)
                  const Text('Running...', style: TextStyle(fontWeight: FontWeight.bold))
                else if (_copied)
                  const Text('Copy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                else
                  const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: SelectableText(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
