import 'dart:async';
import 'dart:io' as io;
import 'package:owlistic/owlistic.dart';

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

  io.exit(0);
}
