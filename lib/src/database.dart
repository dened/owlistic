// ignore_for_file: prefer_foreach
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart' as ffi;
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:owlistic/src/constant/constants.dart';
import 'package:owlistic/src/dto/cetrificate_entity.dart';
import 'package:owlistic/src/dto/search_info.dart' as m;

part 'database.g.dart';

/// Key-value storage interface for SQLite database
abstract interface class IKeyValueStorage {
  /// Refresh key-value storage from database
  Future<void> refresh();

  /// Get value by key
  T? getKey<T extends Object>(String key);

  /// Set value by key
  void setKey(String key, Object? value);

  /// Remove value by key
  void removeKey(String key);

  /// Get all values
  Map<String, Object?> getAll([Set<String>? keys]);

  /// Set all values
  void setAll(Map<String, Object?> data);

  /// Remove all values
  void removeAll([Set<String>? keys]);
}

@DriftDatabase(
  include: <String>{
    'ddl/kv.drift',
    'ddl/certification.drift',
    'ddl/search_info.drift',
    'ddl/user.drift',
  },
)
class Database extends _$Database
    with _DatabaseSearchInfoMixin, _DatabaseKeyValueMixin, _UserInfoMixin
    implements IKeyValueStorage {
  Database.lazy({String? path, bool logStatements = false, bool dropDatabase = false})
      : super(LazyDatabase(
          () => _createQueryExecutor(
            path: path,
            logStatements: logStatements,
            dropDatabase: dropDatabase,
          ),
        ));

  static Future<QueryExecutor> _createQueryExecutor({
    String? path,
    bool logStatements = false,
    bool dropDatabase = false,
    bool memoryDatabase = false,
  }) async {
    if (kDebugMode) {
      try {
        ffi.NativeDatabase.closeExistingInstances();
      } on Object catch (error, stackTrace) {
        l.e('Error closing existing instances: $error', stackTrace);
      }
    }

    const memory = <String>{':memory:', 'memory', 'mem', 'ram', 'tempdb', 'temp', 'tmp', 'test', 'testing', 'debug'};

    if (memoryDatabase || memory.contains(path)) {
      return ffi.NativeDatabase.memory(logStatements: logStatements);
    }

    File file;
    if (path == null) {
      var folder = Directory.current;
      folder = Directory(p.join(folder.path, 'data'));
      if (!folder.existsSync()) await folder.create(recursive: true);
      file = File(p.join(folder.path, 'db.sqlite3'));
    } else {
      file = File('${Directory.systemTemp.path}/drift.db');
    }

    try {
      if (dropDatabase && file.existsSync()) {
        await file.delete();
      }
    } on Object catch (error, stackTrace) {
      l.e('Error deleting database file: $error', stackTrace);
    }

    return ffi.NativeDatabase.createInBackground(file, logStatements: logStatements);
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => DatabaseMigrationStrategy(db: this);
}

@immutable
class DatabaseMigrationStrategy implements MigrationStrategy {
  const DatabaseMigrationStrategy({
    required Database db,
  }) : _db = db;

  /// Database to use for migrations.
  final Database _db;

  /// Executes when the database is created for the first time.
  @override
  OnCreate get onCreate => (migrator) async {
        await migrator.createAll();
      };

  /// Executes after the database is ready to be used (ie. it has been opened
  /// and all migrations ran), but before any other queries will be sent. This
  /// makes it a suitable place to populate data after the database has been
  /// created or set sqlite `PRAGMAS` that you need.
  @override
  OnBeforeOpen get beforeOpen => (details) async {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      };

  /// Executes when the database has been opened previously, but the last access
  /// happened at a different [GeneratedDatabase.schemaVersion].
  /// Schema version upgrades and downgrades will both be run here.
  @override
  OnUpgrade get onUpgrade => (m, from, to) async {
        if (from == to) return;
        await _db.customStatement('PRAGMA foreign_keys = OFF;');
        return _update(_db, m, from, to);
      };

  /// https://drift.simonbinder.eu/migrations/
  static Future<void> _update(Database db, Migrator m, int from, int to) async {
    if (from >= to) return;

    switch (from) {
      case 1:
        await m.createAll();
        break;
      default:
        if (kDebugMode) throw UnimplementedError('Unknown migration from $from to $to');
    }

    // Recursively upgrade to the latest version
    await _update(db, m, from + 1, to);
  }
}

mixin _DatabaseKeyValueMixin on _$Database implements IKeyValueStorage {
  bool _isInitialized = false;
  final Map<String, Object> _cache = <String, Object>{};

  static KvTableCompanion? _kvCompanionFromKeyValue(String key, Object? value) => switch (value) {
        int vint => KvTableCompanion.insert(k: key, vint: Value(vint)),
        double vfloat => KvTableCompanion.insert(k: key, vfloat: Value(vfloat)),
        String vstring => KvTableCompanion.insert(k: key, vstring: Value(vstring)),
        bool vbool => KvTableCompanion.insert(k: key, vbool: Value(vbool ? 1 : 0)),
        _ => null,
      };
  @override
  Future<void> refresh() => select(kvTable).get().then((value) {
        _isInitialized = true;
        _cache
          ..clear()
          ..addAll(<String, Object>{for (final kv in value) kv.k: kv.vstring ?? kv.vint ?? kv.vfloat ?? kv.vbool == 1});
      });

  @override
  T? getKey<T extends Object>(String key) {
    assert(_isInitialized, 'Database must be initialized before use.');
    final value = _cache[key];
    if (value is T) {
      return value;
    } else if (value == null) {
      return null;
    } else {
      assert(false, 'Value for key $key is not of type $T');
      l.e('Value for key $key is not of type $T');
      return null;
    }
  }

  @override
  void setKey(String key, Object? value) {
    assert(_isInitialized, 'Database must be initialized before use.');
    if (value == null) return removeKey(key);

    _cache[key] = value;
    final entity = _kvCompanionFromKeyValue(key, value);
    if (entity == null) {
      assert(false, 'Value $value for key $key is not of supported type');
      l.e('Value $value for key $key is not of supported type');
      return;
    }

    into(kvTable).insertOnConflictUpdate(entity).ignore();
  }

  @override
  void removeKey(String key) {
    assert(_isInitialized, 'Database must be initialized before use.');
    _cache.remove(key);
    (delete(kvTable)..where((tbl) => tbl.k.equals(key))).go().ignore();
  }

  @override
  Map<String, Object?> getAll([Set<String>? keys]) {
    assert(_isInitialized, 'Database must be initialized before use.');
    return keys == null
        ? Map<String, Object>.of(_cache)
        : <String, Object>{
            for (final e in _cache.entries)
              if (keys.contains(e.key)) e.key: e.value,
          };
  }

  @override
  void setAll(Map<String, Object?> data) {
    assert(_isInitialized, 'Database must be initialized before use.');
    if (data.isEmpty) return;

    final entries = <(String, Object?, KvTableCompanion?)>[
      for (final entry in data.entries) (entry.key, entry.value, _kvCompanionFromKeyValue(entry.key, entry.value))
    ];
    final toDelete = entries.where((e) => e.$3 == null).map<String>((e) => e.$1).toSet();
    final toInsert = entries.expand<(String, Object, KvTableCompanion)>((e) sync* {
      final value = e.$2;
      final companion = e.$3;
      if (companion == null || value == null) return;
      yield (e.$1, value, companion);
    }).toList();

    for (final key in toDelete) _cache.remove(key);
    _cache.addAll(<String, Object>{for (final e in toInsert) e.$1: e.$2});

    batch((b) => b
      ..deleteWhere(kvTable, (tbl) => tbl.k.isIn(toDelete))
      ..insertAllOnConflictUpdate(kvTable, toInsert.map((e) => e.$3).toList(growable: false))).ignore();
  }

  @override
  void removeAll([Set<String>? keys]) {
    assert(_isInitialized, 'Database must be initialized before use.');
    if (keys == null) {
      _cache.clear();
      delete(kvTable).go().ignore();
    } else if (keys.isNotEmpty) {
      for (final key in keys) _cache.remove(key);
      (delete(kvTable)..where((tbl) => tbl.k.isIn(keys))).go().ignore();
    }
  }
}

mixin _UserInfoMixin on _$Database {
  /// Saves user information into the database.
  /// If the user already exists, it will update the existing record.
  Future<void> saveUser({
    required int id,
    String? firstName,
    String? lastName,
    String? username,
    String? languageCode,
  }) async {
    // Implement the logic to save user data into the database
    await into(user).insertOnConflictUpdate(UserCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      username: Value(username),
      languageCode: Value(languageCode),
    ));
  }
}

mixin _DatabaseSearchInfoMixin on _$Database {
  /// Get search info by userId ID and isRemoved == false
  /// Returns a list of [SearchInfoData] for the given chat ID.
  Future<List<m.SearchInfo>> getSearchInfo(int chatId) async {
    final query = select(searchInfo)
      ..where((tbl) =>
          tbl.userId.equals(chatId) &
          tbl.isDeleted.equals(0) &
          notExistsQuery(select(certification)..where((cert) => cert.searchInfoId.equalsExp(tbl.id))));

    return query.map((s) => s.toSearchInfo()).get();
  }

  /// Returns a list of [SearchInfo] that are valid and not deleted,
  /// and for which there are no associated certifications.
  /// This method orders the results by userId in ascending order.
  Future<List<m.SearchInfo>> getAllSearchInfo() async {
    final query = select(searchInfo)
      ..where((tbl) =>
          tbl.isValid.equals(1) &
          tbl.isDeleted.equals(0) &
          notExistsQuery(select(certification)..where((cert) => cert.searchInfoId.equalsExp(tbl.id))))
      ..orderBy([(u) => OrderingTerm(expression: u.userId, mode: OrderingMode.asc)]);

    return query.map((s) => s.toSearchInfo()).get();
  }

  /// Marks all search info records for a given chat ID as deleted.
  Future<int> deleteAllSearchInfo(int chatId) {
    assert(chatId > 0, 'Chat ID must be greater than 0');
    return (update(searchInfo)..where((tbl) => tbl.userId.equals(chatId)))
        .write(const SearchInfoCompanion(isDeleted: Value(1)));
  }

  /// Marks a search info record by its ID as deleted.
  Future<int> deleteSearchInfo(int id) {
    assert(id > 0, 'id must be greater than 0');
    return (update(searchInfo)..where((tbl) => tbl.id.equals(id)))
        .write(const SearchInfoCompanion(isDeleted: Value(1)));
  }

  Future<void> saveCertificate({
    required int searchInfoId,
    required String link,
    required CertificateEntity entity,
  }) async {
    await into(certification).insert(CertificationCompanion(
      searchInfoId: Value(searchInfoId),
      link: Value(link),
      data: Value(jsonEncode(entity.toJson())),
    ));
  }
}

extension SearchInfoDataExtension on SearchInfoData {
  /// Converts this [SearchInfoData] to a [m.SearchInfo] object.
  m.SearchInfo toSearchInfo() => m.SearchInfo(
        id: id,
        chatId: userId,
        nummer: attendeeNumber,
        examDate: DateTime.fromMillisecondsSinceEpoch(examDate * 1000),
        birthDate: DateTime.fromMillisecondsSinceEpoch(birthDate * 1000),
      );
}
