import 'package:brix/brix.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class Item {
  const Item(this.id, this.name);

  factory Item.fromJson(Json json) =>
      Item(json.string('id'), json.string('name'));

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

void main() {
  late BrixStorage storage;
  late BrixOfflineCache<Item> cache;
  final when = DateTime(2026, 11, 2, 10);

  setUp(() {
    final memory = MemoryStore();
    storage = BrixStorage(values: memory, secrets: memory);
    cache = BrixOfflineCache<Item>(
      storage: storage,
      key: 'items',
      idOf: (item) => item.id,
      toJson: (item) => item.toJson(),
      fromJson: Item.fromJson,
      now: () => when,
    );
  });

  Future<Result<List<Item>>> ok(List<Item> items) async => Success(items);
  Future<Result<List<Item>>> offline() async => Failed(NetworkFailure());
  bool byName(Item item, String query) =>
      item.name.toLowerCase().contains(query);

  test('fetch returns fresh data and saves it', () async {
    final result = await cache.fetch(() => ok([const Item('1', 'SUN2000')]));
    final data = (result as Success<BrixCached<List<Item>>>).data;
    expect(data.fromCache, isFalse);
    expect((await cache.saved()).single.name, 'SUN2000');
    expect(await cache.savedAt(), when);
  });

  test('fetch falls back to the saved copy without a connection', () async {
    await cache.fetch(() => ok([const Item('1', 'SUN2000')]));
    final result = await cache.fetch(offline);
    final data = (result as Success<BrixCached<List<Item>>>).data;
    expect(data.fromCache, isTrue);
    expect(data.savedAt, when);
    expect(data.data.single.id, '1');
  });

  test('server errors fall back too, other failures do not', () async {
    await cache.fetch(() => ok([const Item('1', 'SUN2000')]));
    final server = await cache.fetch(
      () async => Failed(ServerFailure(statusCode: 503)),
    );
    expect(server, isA<Success<BrixCached<List<Item>>>>());
    final rejected = await cache.fetch(() async => Failed(ValidationFailure()));
    expect((rejected as Failed).failure, isA<ValidationFailure>());
  });

  test('without a saved copy the failure is returned', () async {
    final result = await cache.fetch(offline);
    expect((result as Failed).failure, isA<NetworkFailure>());
  });

  test('fetch replaces the copy, search merges into it', () async {
    await cache.fetch(
      () => ok([const Item('1', 'SUN2000'), const Item('2', 'SG 10 RT')]),
    );
    await cache.fetch(() => ok([const Item('3', 'GW5000')]));
    expect((await cache.saved()).map((i) => i.id), ['3']);
    await cache.search(
      'fox',
      online: () => ok([const Item('4', 'Fox G3')]),
      matches: byName,
    );
    await cache.search(
      'gw',
      online: () => ok([const Item('3', 'GW5000 new')]),
      matches: byName,
    );
    final saved = await cache.saved();
    expect(saved.map((i) => i.id), ['4', '3']);
    expect(saved.last.name, 'GW5000 new');
  });

  test(
    'offline search filters the saved copy with the lower case query',
    () async {
      await cache.fetch(
        () => ok([const Item('1', 'SUN2000'), const Item('2', 'SG 10 RT')]),
      );
      final result = await cache.search(
        ' SUN ',
        online: offline,
        matches: byName,
      );
      final data = (result as Success<BrixCached<List<Item>>>).data;
      expect(data.fromCache, isTrue);
      expect(data.data.map((i) => i.id), ['1']);
    },
  );

  test('keeps at most maxItems, the newest win', () async {
    final small = BrixOfflineCache<Item>(
      storage: storage,
      key: 'small',
      idOf: (item) => item.id,
      toJson: (item) => item.toJson(),
      fromJson: Item.fromJson,
      maxItems: 2,
    );
    await small.search(
      'a',
      online: () => ok([const Item('1', 'a'), const Item('2', 'b')]),
      matches: byName,
    );
    await small.search(
      'c',
      online: () => ok([const Item('3', 'c')]),
      matches: byName,
    );
    expect((await small.saved()).map((i) => i.id), ['2', '3']);
  });

  test('a broken saved item is skipped, clear removes the copy', () async {
    await storage.writeJson('items', {
      'savedAt': 'x',
      'items': [
        {'id': '1', 'name': 'ok'},
        'broken',
      ],
    });
    expect((await cache.saved()).single.name, 'ok');
    expect(await cache.savedAt(), isNull);
    await cache.clear();
    expect(await cache.saved(), isEmpty);
  });
}
