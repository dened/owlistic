import 'dart:async';

import 'package:telc_result_checker/src/telegram_bot/context.dart';

abstract class BaseHandler {
  bool canHandle(Context ctx);

  FutureOr<void> handle(Context ctx);
}
