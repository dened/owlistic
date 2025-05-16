// ignore_for_file: prefer_foreach
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart' as ffi;
import 'package:l/l.dart';
import 'package:path/path.dart' as p;
import 'package:telc_result_checker/src/constant/constants.dart';

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
  },
)
class Database extends _$Database with _DatabaseKeyValueMixin implements IKeyValueStorage {
  Database.lazy({String? path, bool logStatements = false, bool dropDatabase = false})
      : super(LazyDatabase(
          () => _createQueryExecutor(
            path: path,
            logStatements: logStatements,
            dropDatabase: dropDatabase,
          ),
        ));

  @override
  int get schemaVersion => 1;

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
