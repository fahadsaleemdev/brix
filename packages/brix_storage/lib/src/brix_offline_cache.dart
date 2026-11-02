import 'package:brix/brix.dart';

import 'brix_storage.dart';

/// A list that also works offline: every answer from your backend is saved
/// on the device, and when the backend cannot be reached the saved copy is
/// used instead. Back online, the backend wins again and the copy is
/// refreshed.
///
/// ```dart
/// final inverters = BrixOfflineCache<Inverter>(
///   storage: storage,
///   key: 'catalog.inverters',
///   idOf: (inverter) => inverter.id,
///   toJson: (inverter) => inverter.toJson(),
///   fromJson: Inverter.fromJson,
/// );
///
/// // The whole list (replaces the saved copy):
/// final all = await inverters.fetch(() => api.getInverters());
///
/// // A search: the backend when online, the saved copy when offline.
/// final found = await inverters.search(
///   text,
///   online: () => api.searchInverters(text),
///   matches: (inverter, text) => inverter.name.toLowerCase().contains(text),
/// );
/// ```
///
/// Only a [NetworkFailure] or a [ServerFailure] falls back to the saved
/// copy; any other failure (e.g. a rejected request) is returned as it is.
class BrixOfflineCache<T> {
  BrixOfflineCache({
    required this.storage,
    required this.key,
    required this.idOf,
    required this.toJson,
    required this.fromJson,
    this.maxItems = 2000,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final BrixStorage storage;

  /// Where the copy is saved; one key per list.
  final String key;

  /// A stable id per item, so search answers are merged into the copy
  /// without duplicates.
  final String Function(T item) idOf;

  final Map<String, dynamic> Function(T item) toJson;
  final T Function(Json json) fromJson;

  /// The most items kept; the newest answers win.
  final int maxItems;

  final DateTime Function() _now;

  /// The whole list from [online]. On success the saved copy is replaced;
  /// without a connection the saved copy is returned.
  Future<Result<BrixCached<List<T>>>> fetch(
    Future<Result<List<T>>> Function() online,
  ) async {
    final result = await online();
    switch (result) {
      case Success(:final data, :final message):
        await _save(data, replace: true);
        return Success(BrixCached(data, fromCache: false), message: message);
      case Failed(:final failure):
        return _fallback(failure, (items) => items);
    }
  }

  /// A search on [online]. Its answer is merged into the saved copy; without
  /// a connection the saved copy is searched with [matches] (given the
  /// trimmed, lower case [query]).
  Future<Result<BrixCached<List<T>>>> search(
    String query, {
    required Future<Result<List<T>>> Function() online,
    required bool Function(T item, String query) matches,
  }) async {
    final result = await online();
    switch (result) {
      case Success(:final data, :final message):
        await _save(data, replace: false);
        return Success(BrixCached(data, fromCache: false), message: message);
      case Failed(:final failure):
        final text = query.trim().toLowerCase();
        return _fallback(
          failure,
          (items) => items.where((item) => matches(item, text)).toList(),
        );
    }
  }

  /// The saved copy, or an empty list.
  Future<List<T>> saved() async => (await _read())?.items ?? <T>[];

  /// When the copy was last saved, or `null` when there is none.
  Future<DateTime?> savedAt() async => (await _read())?.savedAt;

  /// Deletes the saved copy (e.g. on logout).
  Future<void> clear() => storage.delete(key);

  Future<Result<BrixCached<List<T>>>> _fallback(
    Failure failure,
    List<T> Function(List<T> items) pick,
  ) async {
    if (failure is! NetworkFailure && failure is! ServerFailure) {
      return Failed(failure);
    }
    final copy = await _read();
    if (copy == null) return Failed(failure);
    return Success(
      BrixCached(pick(copy.items), fromCache: true, savedAt: copy.savedAt),
    );
  }

  Future<void> _save(List<T> items, {required bool replace}) async {
    final merged = <String, T>{};
    if (!replace) {
      for (final item in (await _read())?.items ?? <T>[]) {
        merged[idOf(item)] = item;
      }
    }
    for (final item in items) {
      merged.remove(idOf(item)); // move to the end: newest last
      merged[idOf(item)] = item;
    }
    var list = merged.values.toList();
    if (list.length > maxItems) list = list.sublist(list.length - maxItems);
    await storage.writeJson(key, {
      'savedAt': _now().toIso8601String(),
      'items': [for (final item in list) toJson(item)],
    });
  }

  Future<({List<T> items, DateTime? savedAt})?> _read() async {
    final saved = await storage.readJson(key);
    if (saved == null) return null;
    final raw = saved['items'];
    if (raw is! List) return null;
    final items = <T>[];
    for (final entry in raw) {
      if (entry is Map) {
        try {
          items.add(fromJson(Json(Map<String, dynamic>.from(entry))));
        } catch (error, stackTrace) {
          storage.onError?.call(error, stackTrace); // skip a broken item
        }
      }
    }
    final at = saved['savedAt'];
    return (items: items, savedAt: at is String ? DateTime.tryParse(at) : null);
  }
}

/// Data from [BrixOfflineCache] and where it came from.
class BrixCached<T> {
  const BrixCached(this.data, {required this.fromCache, this.savedAt});

  final T data;

  /// `true` when the backend could not be reached and this is the saved
  /// copy, e.g. to show "Offline, saved data".
  final bool fromCache;

  /// When the saved copy was written; `null` for fresh data.
  final DateTime? savedAt;
}
