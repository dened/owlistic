import 'package:l/l.dart';
import 'package:telc_result_checker/src/constant/constants.dart';
import 'package:telc_result_checker/src/database.dart' show Database;
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/lookup_service/lookup_service_handler.dart';
import 'package:telc_result_checker/src/retry.dart';
import 'package:telc_result_checker/src/lookup_service/telc_api_client.dart';

/// [TelcCertificateLookupService] lookup certificates using the Telc API.
/// This service is responsible for searching for certificates based on
/// user-provided information such as number, birth date, and exam date.
/// It handles the lookup process, including searching for certificate information
/// and fetching the certificate data from the API.
/// It also manages the storage of search information and
/// notifies the handler when a certificate is found or not found.
final class TelcCertificateLookupService {
  TelcCertificateLookupService({
    required TelcApiClient apiClient,
    required Database db,
    required LookupServiceHandler handler,
  })  : _apiClient = apiClient,
        _db = db,
        _handler = handler;

  final TelcApiClient _apiClient;
  final Database _db;
  final LookupServiceHandler _handler;

  /// Starts the certificate lookup process.
  /// It retrieves the search information from storage,
  /// flattens it into a list of search tasks, and processes them in batches.
  Future<void> start() async {
    // final usersSearchInfoMap = await storage.usersSearchInfoMap();
    // Flatten all search tasks into a single list with chatId
    final allSearchTasks = await _db.getAllSearchInfo();

    const batchSize = 3;
    const batchDelay = Duration(seconds: 2);

    for (var i = 0; i < allSearchTasks.length; i += batchSize) {
      final batch = allSearchTasks.skip(i).take(batchSize);
      await Future.wait(batch.map((info) async {
        try {
          final (examinationInstituteId, examId, attendeeId) = await _lookupCert(
            info.nummer,
            info.birthDate,
            createCheckedDateList(info.examDate, DateTime.now(), daysForCheck),
          );

          /// Make several attempts to fetch certificate data, as the data should definitely exist.
          /// The error might be related to a temporary failure on the API side.
          final certificate = await retry(() => _apiClient.fetchCertificateData(
                examinationInstituteId,
                examId,
                attendeeId,
              ));

          _handler
              .certFound(
                searchInfo: info,
                link: 'https://results.telc.net/certificate/$examinationInstituteId/$examId/$attendeeId',
                certificate: certificate,
              )
              .ignore();
          l.d('Certificate data: $certificate');
        } on CertInfoNotFoundException {
          l.i('Certificate not found for ${info.nummer} on ${info.examDate.toTeclFormat()}');
          _handler.certNotFound(info).ignore();
        } on Object catch (error, stackTrace) {
          l.e('An error occurred while checking certificates: $error', stackTrace);
        }
      }));
      // Add delay between batches except after the last batch
      if (i + batchSize < allSearchTasks.length) {
        await Future<void>.delayed(batchDelay);
      }
    }
  }

  /// Looks up the certificate information for a given [number] and [birthDate].
  /// It searches for the certificate information in a range of [dateList]
  Future<CertInfo> _lookupCert(String nummer, DateTime birthDate, List<DateTime> dateList) async {
    l.i('🔍 Starting search from ${dateList.first.toTeclFormat()} to ${dateList.last.toTeclFormat()} for $nummer...');
    for (final date in dateList) {
      try {
        final certInfo = await _apiClient.searchCertInfo(nummer, date, birthDate);
        l.i('✅ Certificate found for [$nummer, ${date.toTeclFormat()}]');

        return certInfo;
      } on CertInfoNotFoundException {
        l.i('❌ No data for $nummer on ${date.toTeclFormat()}');
      } on Object catch (error, stackTrace) {
        l.e(
          '⚠️ Error occurred while searching for certificate. '
          'nummer: $nummer, birthDate: ${birthDate.toTeclFormat()}, '
          'Error: $error',
          stackTrace,
        );
        rethrow;
      }
    }
    l.i('Stop searching. Certificate not found');

    throw CertInfoNotFoundException();
  }
}
