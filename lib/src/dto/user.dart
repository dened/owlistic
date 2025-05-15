import 'package:json_annotation/json_annotation.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/dto/user_info.dart';

part 'user.g.dart';

@JsonSerializable()
class User {

  User({
    required this.userInfo,
    required this.searchInfoList,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final UserInfo userInfo;
  final List<SearchInfo> searchInfoList;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

