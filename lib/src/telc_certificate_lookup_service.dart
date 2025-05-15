import 'package:l/l.dart';
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/dto/user.dart';
import 'package:telc_result_checker/src/dto/user_info.dart';
import 'package:telc_result_checker/src/storage/storage.dart';
import 'package:telc_result_checker/src/telc_api_client.dart';

final class TelcCertificateLookupService {
  TelcCertificateLookupService({
    required this.apiClient,
    required this.storage,
  });

  final TelcApiClient apiClient;
  final Storage storage;

  Future<void> start() async {
    final usersSearchInfoList = await storage.usersSearchInfoList();
    for (final entry in usersSearchInfoList.entries) {
      final id = entry.key;
      final searchInfoList = entry.value;
      for (final searchInfo in searchInfoList) {
        try {
          final certInfo = await lookupCert(searchInfo.nummer, searchInfo.examDate, searchInfo.birthDate);
        } catch (e) {
          // Handle exceptions
        }
      }
    }
  }

  Future<CertInfo> lookupCert(String nummer, DateTime examDate, DateTime birthDate) async {
    final dateList = createCheckedDateList(examDate, DateTime.now());
    l.i('🔍 Starting search from ${dateList.first} to ${dateList.last} for $nummer...');
    for (final date in dateList) {
      try {
        final certInfo = await apiClient.searchCertInfo(nummer, date, birthDate);
        l.i('✅ Certificate found for [$nummer, ${date.toTeclFormat()}]');

        return certInfo;
      } on CertInfoNotFoundException {
        l.i('❌ No data for $nummer on ${date.toTeclFormat()}');
      } on Object catch (error, stackTrace) {
        l.e('⚠️ Error searching for certificate: $error', stackTrace);
      }
    }
    throw CertInfoNotFoundException();
  }
}
