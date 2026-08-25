import 'package:flutter_test/flutter_test.dart';
import 'package:coachboard/core/calc/coach_math.dart';

void main() {
  test('attendance is attended over scheduled', () {
    expect(CoachMath.attendanceRate(19, 22), closeTo(19 / 22, 1e-9));
    expect(CoachMath.attendanceRate(0, 0), 0);
  });

  test('pack leftover never goes negative', () {
    expect(CoachMath.remainingSessions(12, 5), 7);
    expect(CoachMath.remainingSessions(8, 10), 0);
  });

  test('weight delta is last minus first', () {
    expect(CoachMath.weightDelta([178.2, 180.6]), closeTo(2.4, 1e-9));
    expect(CoachMath.weightDelta([180]), 0);
  });

  test('clock pads minutes and seconds', () {
    expect(CoachMath.clock(34 * 60 + 27), '34:27');
    expect(CoachMath.money(4250), r'$4250.00');
  });
}
