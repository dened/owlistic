import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:l/l.dart';
import 'package:telc_result_checker/date_utils.dart';

const nummer = '0378181';
const birthDate = '19-09-1988';
final examDate = DateTime(2025, 4, 15);

Future<void> main() async {
  l.capture(() => runZonedGuarded<void>(() async {
        final dateList = createCheckedDateList(examDate, DateTime.now());

        l.i('🔍 Starting search from ${dateList.first} to ${dateList.last}...');

        final client = HttpClient();
        for (final date in dateList) {
          final checkDateStr = date.toIso8601String().split('T').first;
          final url =
              'https://results.telc.net/api/results/loopkup/$nummer/pruefung/$checkDateStr/birthdate/$birthDate';
          final uri = Uri.parse(url);
          try {
            final request = await client.getUrl(uri);
            final response = await request.close();
            if (response.statusCode == 200) {
              final responseBody = await response.transform(utf8.decoder).join();
              l
                ..v('✅ Certificate found for $checkDateStr')
                ..v('Response: $responseBody');
              break;
            } else if (response.statusCode == 404) {
              l.v('❌ No data for $checkDateStr');
            } else {
              l.e('⚠️ Error ${response.statusCode} on $checkDateStr');
            }
          } on Exception catch (e) {
            l.e('💥 Request error on $checkDateStr: $e');
          }
        }
        client.close();
        l.i('🔁 Search completed');
      }, (error, stackTrace) {
        l.e('An top level error occurred. $error', stackTrace);
        debugger(); // Set a breakpoint here
      }));
}
