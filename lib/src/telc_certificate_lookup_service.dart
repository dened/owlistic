import 'package:l/l.dart';
import 'package:telc_result_checker/src/constant/constants.dart';
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/lookup_service_handler.dart';
import 'package:telc_result_checker/src/storage/storage.dart';
import 'package:telc_result_checker/src/telc_api_client.dart';

/// [TelcCertificateLookupService] lookup certificates using the Telc API.
/// This service is responsible for searching for certificates based on
/// user-provided information such as number, birth date, and exam date.
/// It handles the lookup process, including searching for certificate information
/// and fetching the certificate data from the API.
/// It also manages the storage of search information and
/// notifies the handler when a certificate is found or not found. 
final class TelcCertificateLookupService {
  TelcCertificateLookupService({
    required this.apiClient,
    required this.storage,
    required this.handler,
  });

  final TelcApiClient apiClient;
  final Storage storage;
  final LookupServiceHandler handler;

  /// Starts the certificate lookup process.
  /// It retrieves the search information from storage,
  /// flattens it into a list of search tasks, and processes them in batches.
  Future<void> start() async {
    final usersSearchInfoMap = await storage.usersSearchInfoMap();
    // Flatten all search tasks into a single list with chatId
    final allSearchTasks = <MapEntry<String, SearchInfo>>[];
    usersSearchInfoMap.forEach((chatId, searchInfoList) {
      for (final searchInfo in searchInfoList) {
        allSearchTasks.add(MapEntry(chatId, searchInfo));
      }
    });

    const batchSize = 3;
    const batchDelay = Duration(seconds: 2);

    for (var i = 0; i < allSearchTasks.length; i += batchSize) {
      final batch = allSearchTasks.skip(i).take(batchSize);
      await Future.wait(batch.map((entry) async {
        final chatId = entry.key;
        final searchInfo = entry.value;
        try {
          final (examinationInstituteId, examId, attendeeId) = await _lookupCert(
            searchInfo.nummer,
            searchInfo.birthDate,
            createCheckedDateList(searchInfo.examDate, DateTime.now(), daysForCheck),
          );
          final certificate = await apiClient.fetchCertificateData(
            examinationInstituteId,
            examId,
            attendeeId,
          );
          handler.certFound(chatId, certificate).ignore();
          l.d('Certificate data: $certificate');
        } on CertInfoNotFoundException {
          l.i('Certificate not found for ${searchInfo.nummer} on ${searchInfo.examDate.toTeclFormat()}');
          handler.certNotFound(chatId, searchInfo).ignore();
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
        final certInfo = await apiClient.searchCertInfo(nummer, date, birthDate);
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
