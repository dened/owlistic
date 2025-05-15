import 'package:json_annotation/json_annotation.dart';

part 'cetrificate.g.dart';

@JsonSerializable(explicitToJson: true)
class Certificate {
  final String language;
  final List<ContentItem> content;

  Certificate({required this.language, required this.content});

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ContentItem {
  @JsonKey(unknownEnumValue: TopLevelContentType.unknown)
  final TopLevelContentType type;
  final List<NestedContentItem> content;

  ContentItem({required this.type, required this.content});

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContentItemToJson(this);
}

@JsonSerializable()
class NestedContentItem {
  @JsonKey(unknownEnumValue: NestedContentType.unknown)
  final NestedContentType type;
  final String? content;
  final String? title;
  final String? points;
  final int? decimalPlaces;
  final bool? specialConditions;
  final bool? isMainTotal;

  NestedContentItem({
    required this.type,
    this.content,
    this.title,
    this.points,
    this.decimalPlaces,
    this.specialConditions,
    this.isMainTotal,
  });

  factory NestedContentItem.fromJson(Map<String, dynamic> json) =>
      _$NestedContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$NestedContentItemToJson(this);
}

enum TopLevelContentType {
  certHead,
  personalData,
  grades,
  generalData,
  unknown // Fallback for unknown values
}

enum NestedContentType {
  headline1,
  headline2,
  lastname,
  firstname,
  dateOfBirth,
  placeOfBirth,
  pointsAndText,
  resultText,
  date,
  titleAndText,
  additionalTextForSpecialConditionAndCreditAllocation,
  unknown // Fallback for unknown values
}