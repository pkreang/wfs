T? getFirstOrNull<T>(List<T>? list) {
  if (list == null || list.isEmpty) return null;
  return list.first;
}
