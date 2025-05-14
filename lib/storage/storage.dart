import 'dart:async';

import 'package:telc_result_checker/dto/search_info.dart';
import 'package:telc_result_checker/dto/user.dart';

abstract interface class Storage {
 FutureOr<List<SearchInfo>> infoListById(String id);
 FutureOr<void> addSearchInfo(String id, SearchInfo info);
 FutureOr<void> removeSearchInfo(String id, SearchInfo info);
 FutureOr<void> addUser(String id, User user);
}