import 'dart:async';
import 'dart:developer';


import 'package:l/l.dart';
import 'package:telc_result_checker/owlistic.dart';


Future<void> main() async {
  l.capture(() => runZonedGuarded<void>(() async {
        final storage = FileStorage('data/data.json');
        await storage.refresh();
        final apiClient = TelcApiClient();
        final service = TelcCertificateLookupService(
          apiClient: apiClient,
          storage: storage,
        );
        await service.start();
      }, (error, stackTrace) {
        l.e('An top level error occurred. $error', stackTrace);
        debugger(); // Set a breakpoint here
      }));
}
