import 'dart:async';

import 'package:owlistic/src/telegram_bot/context.dart';

/// Abstract class defining a contract for guard classes.
///
/// Guards are used to implement access control logic before a handler
/// is executed. They can allow or deny specific actions or access
/// based on the provided [Context].
abstract class Guard {
  /// Determines if the action or access can be activated based on the
  /// provided [context].
  ///
  /// This method should return `true` if the action is allowed, and `false`
  /// otherwise. It can perform asynchronous operations, such as database lookups.
  FutureOr<bool> canActivate(Context context);
}

/// A concrete implementation of [Guard] that checks for user consent.
///
/// This guard ensures that a user has accepted the privacy policy
/// before allowing a handler to proceed. If consent is missing,
/// it sends a message to the user informing them that consent is required.
class ConsentGuard implements Guard {
  /// Checks if the user associated with the [context]'s chat ID has given consent.
  ///
  /// Returns `true` if consent is found in the database, `false` otherwise.
  /// If consent is missing, it sends a localized message to the user.
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
