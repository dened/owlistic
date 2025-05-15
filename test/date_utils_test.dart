import 'package:telc_result_checker/src/date_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Returns an empty list if the exam has not started yet', () {
    final startDate = DateTime(2025, 5, 10);
    final currentTime = DateTime(2025, 5, 9); // Day before the exam

    var result = createCheckedDateList(startDate, currentTime);

    expect(result, isEmpty); // The result should be an empty list
  });

  test('Returns dates if less than 14 days have passed', () {
    final startDate = DateTime(2025, 5, 10);
    final currentTime = DateTime(2025, 5, 14); // 4 days after the exam

    var result = createCheckedDateList(startDate, currentTime);

    expect(result.length, 4); // There should be 4 dates
    expect(result[0], equals(currentTime)); // The first date should be currentTime
    expect(result[3], equals(DateTime(2025, 5, 11))); // The last date should be 2025-05-11
  });

  test('Returns 60 dates if more than 60 days have passed', () {
    final startDate = DateTime(2025, 5, 10);
    final currentTime = DateTime(2025, 7, 10); // More than 60 days after the exam

    var result = createCheckedDateList(startDate, currentTime);

    expect(result.length, 60); // There should be 60 dates
    expect(result[0], equals(startDate)); // The first date should be startDate
    expect(result[59], equals(DateTime(2025, 7, 9))); // The last date should be 2025-07-09
  });

  test('Returns dates if 14 to 60 days have passed', () {
    final startDate = DateTime(2025, 5, 10);
    final currentTime = DateTime(2025, 5, 24); // 14 days after the exam

    var result = createCheckedDateList(startDate, currentTime);

    expect(result.length, 14); // There should be 14 dates
    expect(result[0], equals(currentTime)); // The first date should be currentTime
    expect(result[13], equals(DateTime(2025, 5, 10))); // The last date should be 2025-05-10
  });
}