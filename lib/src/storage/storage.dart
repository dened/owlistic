import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:l/l.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/dto/user.dart';

abstract interface class Storage {
  /// Initializes the storage. This method should be called before using any
  Future<void> refresh();

  FutureOr<Map<String, List<SearchInfo>>> usersSearchInfoList();
  
  FutureOr<List<SearchInfo>> infoListById(String id);

  FutureOr<void> addSearchInfo(String id, SearchInfo info);

  FutureOr<void> removeSearchInfo(String id, SearchInfo info);

  FutureOr<void> addUser(String id, User user);
}

final class FileStorage implements Storage {
  FileStorage(this.path);

  final Map<String, User> _storage = <String, User>{};

  final String path;

  bool _isInitialized = false;

  @override
  Future<void> refresh() async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final content = await file.readAsString();
        final jsonData = (jsonDecode(content) as Map).map(
          (key, value) => MapEntry(key as String, value as Object),
        );
        _storage.clear();
        jsonData.forEach((key, value) {
          _storage[key] = User.fromJson(value as Map<String, dynamic>);
        });
      } else {
        l.w('Storage file not found, creating a new one.');
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode({}));
      }
      _isInitialized = true;
      l.i('Storage initialized successfully.');
    } on Exception catch (error, stackTrace) {
      l.e('Error during initialization: $error', stackTrace);
    }
  }

  Future<void> _saveToFile() async {
    try {
      final file = File(path);
      final jsonData = _storage.map((key, value) => MapEntry(key, value.toJson()));
      await file.writeAsString(jsonEncode(jsonData));
      l.i('Data saved to file successfully.');
    } on Exception catch (error, stackTrace) {
      l.e('Error during saving to file: $error', stackTrace);
    }
  }

  @override
  FutureOr<Map<String, List<SearchInfo>>> usersSearchInfoList() {
    assert(_isInitialized, 'Storage must be initialized before use.');
    return _storage.map((key, user) => MapEntry(key, user.searchInfoList));
  }

  @override
  FutureOr<void> addSearchInfo(String id, SearchInfo info) async {
    assert(_isInitialized, 'Storage must be initialized before use.');
    final user = _storage[id];
    if (user != null) {
      user.searchInfoList.add(info);
      await _saveToFile();
    }
  }

  @override
  FutureOr<void> removeSearchInfo(String id, SearchInfo info) async {
    assert(_isInitialized, 'Storage must be initialized before use.');
    final user = _storage[id];
    if (user != null) {
      user.searchInfoList.remove(info);
      await _saveToFile();
    }
  }

  @override
  FutureOr<List<SearchInfo>> infoListById(String id) {
    assert(_isInitialized, 'Storage must be initialized before use.');
    final user = _storage[id];
    return user?.searchInfoList ?? [];
  }

  @override
  FutureOr<void> addUser(String id, User user) async {
    assert(_isInitialized, 'Storage must be initialized before use.');
    _storage[id] = user;
    await _saveToFile();
  }
}
