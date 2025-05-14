import 'package:json_annotation/json_annotation.dart';

part 'search_info.g.dart';

@JsonSerializable()
class SearchInfo {

  SearchInfo({
    required this.nummer,
    required this.examDate,
    required this.birthDate,
  });

  factory SearchInfo.fromJson(Map<String, dynamic> json) => _$SearchInfoFromJson(json);

  final String nummer;
  final DateTime examDate;
  final DateTime birthDate;


  Map<String, dynamic> toJson() => _$SearchInfoToJson(this);
}

