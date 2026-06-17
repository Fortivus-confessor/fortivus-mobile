T? enumFromString<T>(Iterable<T> values, String? value) {
  if (value == null) return null;
  try {
    return values.firstWhere((e) => (e as Enum).name == value);
  } catch (_) {
    return null;
  }
}