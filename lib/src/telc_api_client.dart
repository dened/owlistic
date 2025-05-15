import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/dto/cetrificate.dart';

typedef CertInfo = (
  String examinationInstituteId,
  String examId,
  String attendeeId,
);
final Converter<List<int>, Map<String, Object?>> _jsonDecoder =
    utf8.decoder.fuse(json.decoder).cast<List<int>, Map<String, Object?>>();

class TelcApiClient {
  TelcApiClient({http.Client? client}) : _client = client ?? http.Client();
  static const String _baseUrl = 'https://results.telc.net/api/results'; // Base URL for the API
  final http.Client _client; // The HTTP client

  Future<CertInfo> searchCertInfo(String nummer, DateTime pruefungDate, DateTime birthDate) async {
    final pruefungDateString = pruefungDate.toTeclFormat();
    final birthDateString = birthDate.toTeclFormat();

    final url = Uri.parse('$_baseUrl/loopkup/$nummer/pruefung/$pruefungDateString/birthdate/$birthDateString');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = _jsonDecoder.convert(response.bodyBytes);
      final examinationInstituteId = data['examinationInstituteId'] as String;
      final examId = data['examId'] as String;
      final attendeeId = data['attendeeId'] as String;
      l.i('✅ Certificate found for [$nummer, $pruefungDateString]');
      return (examinationInstituteId, examId, attendeeId);
    } else if (response.statusCode == 404) {
      throw CertInfoNotFoundException();
    } else {
      l.w('Failed to search cert: status code ${response.statusCode} ', StackTrace.current);
      throw Exception('Failed to search cert: status code ${response.statusCode}');
    }
  }

  Future<Certificate> fetchCertificateData(String examinationInstituteId, String examId, String attendeeId) async {
    final url = Uri.parse('$_baseUrl/certificate/$examinationInstituteId/pruefungen/$examId/teilnehmer/$attendeeId');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return Certificate.fromJson(_jsonDecoder.convert(response.bodyBytes));
    } else if (response.statusCode == 404) {
      l.e('Failed to fetch certificate data', StackTrace.current, {
        'examinationInstituteId': examinationInstituteId,
        'examId': examId,
        'attendeeId': attendeeId,
      });
      throw Exception('Certificate not found for the provided data.');
    } else {
      l.w('Failed to fetch certificate data: ${response.statusCode}', StackTrace.current);
      throw Exception('Failed to fetch certificate data: ${response.statusCode}');
    }
  }
}

class CertInfoNotFoundException implements Exception {
  CertInfoNotFoundException();

  @override
  String toString() => 'CertInfo not found for the provided data.';
}
