List<DateTime> createCheckedDateList(DateTime startDate, DateTime currentTime) {
  final daysAfterExam = currentTime.difference(startDate).inDays;
  if (daysAfterExam <= 0) return List.empty();
  if (daysAfterExam < 14)
    return List.generate(
        daysAfterExam, (i) => currentTime.add(Duration(days: -i)));

  if (daysAfterExam > 60)
    return List.generate(60, (i) => startDate.add((Duration(days: i))));

  return List.generate(
      daysAfterExam.clamp(0, 21), (i) => currentTime.add(Duration(days: -i)));
}
