import 'dart:async';

import 'package:owlistic/src/telegram_bot/context.dart';

/// Абстрактный класс Guard определяет контракт для классов-защитников,
/// которые могут разрешать или запрещать определенные действия или доступ.
abstract class Guard {
  /// Определяет, может ли быть активировано определенное действие
  /// или предоставлен доступ на основе предоставленного [context].
  FutureOr<bool> canActivate(Context context);
}

class ConsentGuard implements Guard {
  @override
  FutureOr<bool> canActivate(Context context) async {
    final chatId = context.chatId;
    final hasConsent = await context.db.hasUserConsent(chatId);

    if (!hasConsent) {
      await context.bot.sendMessage(chatId, context.ln.mustAcceptConsentMessage);

      return false;
    }
    return true;
  }
}
