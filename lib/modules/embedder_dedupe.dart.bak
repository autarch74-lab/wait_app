double simpleJaccard(String a, String b) {
  final sa = a.toLowerCase().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();
  final sb = b.toLowerCase().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();
  final inter = sa.intersection(sb).length;
  final union = sa.union(sb).length;
  if (union == 0) return 0.0;
  return inter / union;
}

List<T> dedupeBySimilarity<T>(List<T> items, String Function(T) toText, double threshold) {
  final used = <int>{};
  final result = <T>[];
  for (var i = 0; i < items.length; i++) {
    if (used.contains(i)) continue;
    result.add(items[i]);
    for (var j = i + 1; j < items.length; j++) {
      if (used.contains(j)) continue;
      final sim = simpleJaccard(toText(items[i]), toText(items[j]));
      if (sim >= threshold) used.add(j);
    }
  }
  return result;
}
