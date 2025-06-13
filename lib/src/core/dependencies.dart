import 'package:owlistic/src/arguments.dart';
import 'package:owlistic/src/database.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/telegram_bot.dart';

class Dependencies {
  Dependencies({required Database db, required TelegramBot bot, required Arguments arguments, required Localization ln})
    : _db = db,
      _bot = bot,
      _arguments = arguments,
      _ln = ln;

  final Database _db;
  final TelegramBot _bot;
  final Arguments _arguments;
  final Localization _ln;

  Database get db => _db;
  TelegramBot get bot => _bot;
  Arguments get arguments => _arguments;
  Localization get ln => _ln;
}
