import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:owlistic/src/date_utils.dart';
import 'package:owlistic/src/dto/certificate_entity.dart';

typedef CertInfo = (
  String examinationInstituteId,
  String examId,
  String attendeeId,
);

final Converter<List<int>, Map<String, Object?>> _jsonDecoder =
    utf8.decoder.fuse(json.decoder).cast<List<int>, Map<String, Object?>>();

/// [TelcApiClient] is a client for interacting with the Telc API.
/// It provides methods to search for certificate information and fetch certificate data.
class TelcApiClient {
  TelcApiClient({
    http.Client? client,
    this.maxRequestsInWindow = 30,
    this.windowDuration = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://results.telc.net/api/results'; // Base URL for the API
  final http.Client _client; // The HTTP client

  /// Maximum number of requests allowed in the [windowDuration].
  final int maxRequestsInWindow;
  /// The duration of the time window for rate limiting.
  final Duration windowDuration;
  final List<DateTime> _requestTimestamps = [];

  /// Searches for certificate information based on the provided number, exam date, and birth date.
  Future<CertInfo> searchCertInfo(String nummer, DateTime pruefungDate, DateTime birthDate) async {
    final pruefungDateString = pruefungDate.toTeclFormat();
    final birthDateString = birthDate.toTeclFormat();

    final url = Uri.parse('$_baseUrl/loopkup/$nummer/pruefung/$pruefungDateString/birthdate/$birthDateString');
    await _acquirePermit();
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

  /// Fetches the certificate data based on the provided examination institute ID, exam ID, and attendee ID.
  Future<CertificateEntity> fetchCertificateData(
      String examinationInstituteId, String examId, String attendeeId) async {
    final url = Uri.parse('$_baseUrl/certificate/$examinationInstituteId/pruefungen/$examId/teilnehmer/$attendeeId');
    await _acquirePermit();
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return CertificateEntity.fromJson(_jsonDecoder.convert(response.bodyBytes));
    } else if (response.statusCode == 404) {
      l.e('Failed to fetch certificate data', StackTrace.current, {
        'examinationInstituteId': examinationInstituteId,
        'examId': examId,
        'attendeeId': attendeeId,
      });
      throw Exception('Certificate not found for the provided data.');
    } else {
      l.e('Failed to fetch certificate data: ${response.statusCode}');
      throw Exception('Failed to fetch certificate data: ${response.statusCode}');
    }
  }

  /// Acquires a permit to make an API request, respecting the rate limit.
  /// If the rate limit is hit, this method will pause execution until a permit can be acquired.
  Future<void> _acquirePermit() async {
    // Loop until a permit is acquired
    // ignore: literal_only_boolean_expressions
    while (true) {
      final now = DateTime.now();
      // Remove timestamps older than the window duration
      _requestTimestamps.removeWhere((timestamp) => now.difference(timestamp) > windowDuration);

      if (_requestTimestamps.length < maxRequestsInWindow) {
        // Permit acquired
        _requestTimestamps.add(now);
        return;
      } else {
        // Rate limit hit, calculate wait time
        final oldestRequestTimeInWindow = _requestTimestamps.first;
        final timePassedSinceOldest = now.difference(oldestRequestTimeInWindow);
        final timeToWait = windowDuration - timePassedSinceOldest;

        l.d('Rate limit reached. Waiting for ${timeToWait.inMilliseconds}ms before next request.');
        await Future<void>.delayed(timeToWait > Duration.zero ? timeToWait : Duration.zero);
      }
    }
  }
}

/// [CertInfoNotFoundException] is thrown when the certificate information is not found
class CertInfoNotFoundException implements Exception {
  CertInfoNotFoundException();

  @override
  String toString() => 'CertInfo not found for the provided data.';
}
