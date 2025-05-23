/// Utility for creating a list of dates to check the certificate
/// [examDate] must naturally be earlier than the current date.
///
/// Dates are created starting from the current date and stepping back by 1 day.
///
/// If the number of days between the current date and the exam date exceeds 60,
/// the list will contain 60 dates starting from the exam date.
/// This case is not expected when using the service, but we include it just in case.
List<DateTime> createCheckedDateList(DateTime examDate, DateTime currentTime, int daysForCheck) {
  final daysAfterExam = currentTime.difference(examDate).inDays;
  if (daysAfterExam <= 0) return List.empty();
  if (daysAfterExam < daysForCheck) return List.generate(daysAfterExam, (i) => currentTime.add(Duration(days: -i)));

  if (daysAfterExam > 60) return List.generate(60, (i) => examDate.add(Duration(days: i)));

  return List.generate(daysAfterExam.clamp(0, daysForCheck), (i) => currentTime.add(Duration(days: -i)));
}

extension DateTimeExtension on DateTime {
  String toTeclFormat() => toIso8601String().split('T').first;
}
