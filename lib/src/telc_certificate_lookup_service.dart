import 'package:l/l.dart';
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/lookup_service_handler.dart';
import 'package:telc_result_checker/src/storage/storage.dart';
import 'package:telc_result_checker/src/telc_api_client.dart';

final class TelcCertificateLookupService {
  TelcCertificateLookupService({
    required this.apiClient,
    required this.storage,
    required this.handler,
  });

  final TelcApiClient apiClient;
  final Storage storage;
  final LookupServiceHandler handler;

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
          final (examinationInstituteId, examId, attendeeId) =
              await lookupCert(searchInfo.nummer, searchInfo.examDate, searchInfo.birthDate);
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

  Future<CertInfo> lookupCert(String nummer, DateTime examDate, DateTime birthDate) async {
    final dateList = createCheckedDateList(examDate, DateTime.now());
    l.i('🔍 Starting search from ${dateList.first.toTeclFormat()} to ${dateList.last.toTeclFormat()} for $nummer...');
    for (final date in dateList) {
      try {
        final certInfo = await apiClient.searchCertInfo(nummer, date, birthDate);
        l.i('✅ Certificate found for [$nummer, ${date.toTeclFormat()}]');

        return certInfo;
      } on CertInfoNotFoundException {
        l.i('❌ No data for $nummer on ${date.toTeclFormat()}');
      } on Object catch (error, stackTrace) {
        final context = {
          'nummer': nummer,
          'examDate': examDate.toTeclFormat(),
          'birthDate': birthDate.toTeclFormat(),
        };
        l.e('⚠️ Error searching for certificate: $error', stackTrace, context);
        rethrow;
      }
    }
    l.i('Stop searching. Certificate not found');

    throw CertInfoNotFoundException();
  }
}
