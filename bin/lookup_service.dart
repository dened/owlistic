import 'dart:async';

import 'package:owlistic/owlistic.dart';
import 'package:owlistic/src/core/app_runner.dart';
import 'package:owlistic/src/lookup_service/lookup_service_handler.dart';

Future<void> main(List<String> args) async {
  await runApplication(args, (dependecies) async {
    final service = TelcCertificateLookupService(
      apiClient: TelcApiClient(),
      db: dependecies.db,
      handler: TelegramNotificationHandler(bot: dependecies.bot, db: dependecies.db, ln: dependecies.ln),
    );

    final chatId = dependecies.arguments.chatId;
    final checkDays = dependecies.arguments.checkDays ?? defaultCountDaysForCheck;

    if (chatId != null) {
      await service.checkByUser(chatId, checkDays);
    } else {
      await service.checkAll(checkDays);
    }
  });
}
