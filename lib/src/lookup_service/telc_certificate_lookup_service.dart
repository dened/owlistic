import 'package:l/l.dart';

import 'package:owlistic/src/database.dart' show Database;
import 'package:owlistic/src/date_utils.dart';
import 'package:owlistic/src/dto/search_info.dart';
import 'package:owlistic/src/lookup_service/lookup_service_handler.dart';
import 'package:owlistic/src/lookup_service/telc_api_client.dart';
import 'package:owlistic/src/retry.dart';

const batchSize = 3;
const batchDelay = Duration(seconds: 2);

/// [TelcCertificateLookupService] lookup certificates using the Telc API.
/// This service is responsible for searching for Telc certificates based on
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
  }) : _apiClient = apiClient,
       _db = db,
       _handler = handler;

  final TelcApiClient _apiClient;
  final Database _db;
  final LookupServiceHandler _handler;

  /// Checks all stored search information for certificates.
  ///
  /// Retrieves all [SearchInfo] entries from the database that are pending a check
  /// and processes them to find corresponding certificates.
  /// The [daysForCheck] parameter specifies the number of days around the exam date to check.
  Future<void> checkAll(int daysForCheck) async {
    // Retrieve all search tasks that need to be processed.
    l.i('Checking all search tasks for certificates during the previous $daysForCheck days...');
    final allSearchTasks = await _db.getAllSearchInfo();
    await _checkSearchInfoList(allSearchTasks, daysForCheck);
  }

  /// Checks search information for a specific user (identified by [chatId]).
  ///
  /// Retrieves [SearchInfo] entries for the given [chatId] from the database
  /// and processes them to find corresponding certificates.
  /// The [daysForCheck] parameter specifies the number of days around the exam date to check.
  Future<void> checkByUser(int chatId, int daysForCheck) async {
    l.i('Checking search tasks for user $chatId for certificates during the previous $daysForCheck days...');
    final searchTask = await _db.getSearchInfo(chatId);
    await _checkSearchInfoList(searchTask, daysForCheck);
  }

  /// Processes a list of [SearchInfo] tasks in batches to find certificates.
  ///
  /// Iterates through the [allSearchTasks], processing them in batches of [batchSize].
  /// For each task, it attempts to find certificate information and then fetches the certificate.
  /// The [daysForCheck] parameter specifies the number of days around the exam date to check.
  Future<void> _checkSearchInfoList(List<SearchInfo> allSearchTasks, int daysForCheck) async {
    l.i('Checking ${allSearchTasks.length} search tasks for certificates...');
    await Future.wait(
      allSearchTasks.map((info) async {
        try {
          final (examinationInstituteId, examId, attendeeId) = await _lookupCert(
            info.nummer,
            info.birthDate,
            createCheckedDateList(info.examDate, DateTime.now(), daysForCheck),
          );

          /// Make several attempts to fetch certificate data, as the data should definitely exist.
          /// The error might be related to a temporary failure on the API side.
          final certificate = await retry(
            () => _apiClient.fetchCertificateData(examinationInstituteId, examId, attendeeId),
          );

          await _handler
              .certFound(
                searchInfo: info,
                link: 'https://results.telc.net/certificate/$examinationInstituteId/$examId/$attendeeId',
                certificate: certificate,
              );
          l.d('Certificate data: $certificate');
        } on CertInfoNotFoundException {
          l.i('Certificate not found for ${info.nummer} on ${info.examDate.toTeclFormat()}');
          await _handler.certNotFound(daysForCheck, info);
        } on Object catch (error, stackTrace) {
          l.e('An error occurred while checking certificates: $error', stackTrace);
        }
      }),
    );

    l.i('All search tasks have been processed.');
  }

  /// Looks up the certificate information for a given [number] and [birthDate].
  /// It iterates through the provided [dateList] (issue dates) to find a matching certificate.
  /// Returns a [CertInfo] tuple containing `(examinationInstituteId, examId, attendeeId)` if found.
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
