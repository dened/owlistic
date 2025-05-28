import 'package:json_annotation/json_annotation.dart';

part 'cetrificate_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class CertificateEntity {
  CertificateEntity({
    required this.language,
    required this.content,
  });

  factory CertificateEntity.fromJson(Map<String, dynamic> json) => _$CertificateEntityFromJson(json);
  final String language;
  final List<CertificateSection> content;

  Map<String, dynamic> toJson() => _$CertificateEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CertificateSection {
  CertificateSection({
    required this.type,
    required this.content,
  });

  factory CertificateSection.fromJson(Map<String, dynamic> json) => CertificateSection(
        type: json['type'] as String,
        content: (json['content'] as List<dynamic>)
            .map((e) => CertificateContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  final String type;
  final List<CertificateContent> content;

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content.map((e) => e.toJson()).toList(),
      };
}

sealed class CertificateContent {
  const CertificateContent(this.type);

  factory CertificateContent.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'headline1':
        return Headline1Content.fromJson(json);
      case 'headline2':
        return Headline2Content.fromJson(json);
      case 'lastname':
        return LastnameContent.fromJson(json);
      case 'firstname':
        return FirstnameContent.fromJson(json);
      case 'dateOfBirth':
        return DateOfBirthContent.fromJson(json);
      case 'placeOfBirth':
        return PlaceOfBirthContent.fromJson(json);
      case 'pointsAndText':
        return PointsAndTextContent.fromJson(json);
      case 'resultText':
        return ResultTextContent.fromJson(json);
      case 'date':
        return DateContent.fromJson(json);
      case 'titleAndText':
        return TitleAndTextContent.fromJson(json);
      case 'additionalTextForSpecialConditionAndCreditAllocation':
        return AdditionalTextForSpecialConditionAndCreditAllocationContent.fromJson(json);
      default:
        return UnknownTypeContent(type: json['type'] as String, data: json);
    }
  }
  final String type;

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class Headline1Content extends CertificateContent {
  Headline1Content({required this.content}) : super('headline1');

  factory Headline1Content.fromJson(Map<String, dynamic> json) => _$Headline1ContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$Headline1ContentToJson(this);
}

@JsonSerializable()
class Headline2Content extends CertificateContent {
  Headline2Content({required this.content}) : super('headline2');

  factory Headline2Content.fromJson(Map<String, dynamic> json) => _$Headline2ContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$Headline2ContentToJson(this);
}

@JsonSerializable()
class LastnameContent extends CertificateContent {
  LastnameContent({required this.content}) : super('lastname');

  factory LastnameContent.fromJson(Map<String, dynamic> json) => _$LastnameContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$LastnameContentToJson(this);
}

@JsonSerializable()
class FirstnameContent extends CertificateContent {
  FirstnameContent({required this.content}) : super('firstname');

  factory FirstnameContent.fromJson(Map<String, dynamic> json) => _$FirstnameContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$FirstnameContentToJson(this);
}

@JsonSerializable()
class DateOfBirthContent extends CertificateContent {
  DateOfBirthContent({required this.content}) : super('dateOfBirth');

  factory DateOfBirthContent.fromJson(Map<String, dynamic> json) => _$DateOfBirthContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$DateOfBirthContentToJson(this);
}

@JsonSerializable()
class PlaceOfBirthContent extends CertificateContent {
  PlaceOfBirthContent({required this.content}) : super('placeOfBirth');

  factory PlaceOfBirthContent.fromJson(Map<String, dynamic> json) => _$PlaceOfBirthContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$PlaceOfBirthContentToJson(this);
}

@JsonSerializable()
class PointsAndTextContent extends CertificateContent {
  PointsAndTextContent({
    required this.title,
    required this.points,
    required this.content,
    required this.decimalPlaces,
    required this.specialConditions,
    required this.isMainTotal,
  }) : super('pointsAndText');

  factory PointsAndTextContent.fromJson(Map<String, dynamic> json) => _$PointsAndTextContentFromJson(json);
  final String title;
  final String points;
  final int content;
  final int decimalPlaces;
  final String specialConditions;

  @JsonKey(defaultValue: false)
  final bool isMainTotal;

  @override
  Map<String, dynamic> toJson() => _$PointsAndTextContentToJson(this);
}

@JsonSerializable()
class ResultTextContent extends CertificateContent {
  ResultTextContent({required this.content}) : super('resultText');

  factory ResultTextContent.fromJson(Map<String, dynamic> json) => _$ResultTextContentFromJson(json);
  final String content;

  @override
  Map<String, dynamic> toJson() => _$ResultTextContentToJson(this);
}

@JsonSerializable()
class DateContent extends CertificateContent {
  DateContent({required this.title, required this.content}) : super('date');

  factory DateContent.fromJson(Map<String, dynamic> json) => _$DateContentFromJson(json);
  final String title;
  final String content;

  @override
  Map<String, dynamic> toJson() => _$DateContentToJson(this);
}

@JsonSerializable()
class TitleAndTextContent extends CertificateContent {
  TitleAndTextContent({required this.title, required this.content}) : super('titleAndText');

  factory TitleAndTextContent.fromJson(Map<String, dynamic> json) => _$TitleAndTextContentFromJson(json);
  final String title;
  final String content;

  @override
  Map<String, dynamic> toJson() => _$TitleAndTextContentToJson(this);
}

@JsonSerializable()
class AdditionalTextForSpecialConditionAndCreditAllocationContent extends CertificateContent {
  AdditionalTextForSpecialConditionAndCreditAllocationContent({
    required this.specialConditions,
    required this.creditAllocation,
  }) : super('additionalTextForSpecialConditionAndCreditAllocation');

  factory AdditionalTextForSpecialConditionAndCreditAllocationContent.fromJson(Map<String, dynamic> json) =>
      _$AdditionalTextForSpecialConditionAndCreditAllocationContentFromJson(json);
  final String specialConditions;
  final String creditAllocation;

  @override
  Map<String, dynamic> toJson() => _$AdditionalTextForSpecialConditionAndCreditAllocationContentToJson(this);
}

/// Handles unknown or unexpected content types.
class UnknownTypeContent extends CertificateContent {
  UnknownTypeContent({required String type, required this.data}) : super(type);

  final Map<String, dynamic> data;

  @override
  Map<String, dynamic> toJson() => data;
}


extension CertificateContentExtension on CertificateEntity {

  CertificateSection get grades => content.firstWhere((section) => section.type == 'grades');
  CertificateSection get personalData => content.firstWhere((section) => section.type == 'personalData');

  Iterable<PointsAndTextContent> get resultInfo =>
      grades.content.whereType<PointsAndTextContent>();
}