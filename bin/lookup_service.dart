import 'dart:async';

import 'package:owlistic/owlistic.dart';
import 'package:owlistic/src/core/app_runner.dart';
import 'package:owlistic/src/lookup_service/lookup_service_handler.dart';

Future<void> main(List<String> args) async {
  await runApplication(args, (db, bot, arguments) async {
    final service = TelcCertificateLookupService(
      apiClient: TelcApiClient(),
      db: db,
      handler: TelegramNotificationHandler(bot: bot, db: db),
    );

    final chatId = arguments.chatId;
    final checkDays = arguments.checkDays ?? defaultCountDaysForCheck;

    if (chatId != null) {
      await service.checkByUser(chatId, checkDays);
    } else {
      await service.checkAll(checkDays);
    }
  });
}
