import 'dart:async';

import 'package:owlistic/src/telegram_bot/context.dart';
import 'package:owlistic/src/telegram_bot/guard.dart';

abstract class BaseHandler {
  BaseHandler({List<Guard>? guards}) : _guards = guards ?? const <Guard>[];

  final List<Guard> _guards;

  bool canHandle(Context ctx);

  FutureOr<void> handle(Context ctx);

  FutureOr<bool> canActivate(Context ctx) async {
    for (final guard in _guards) {
      if (!await guard.canActivate(ctx)) return false;
    }
    return true;
  }
}
