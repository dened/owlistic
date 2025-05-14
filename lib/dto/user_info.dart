import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {

  UserInfo({
    required this.firstName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  final String firstName;

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

