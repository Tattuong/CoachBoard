/// Attendance, money, and progress arithmetic. Not medical advice.
class CoachMath {
  CoachMath._();

  static double attendanceRate(int attended, int scheduled) {
    if (scheduled <= 0) return 0;
    return attended / scheduled;
  }

  static int remainingSessions(int purchased, int used) {
    final left = purchased - used;
    return left < 0 ? 0 : left;
  }

  static double weightDelta(List<double> weights) {
    if (weights.length < 2) return 0;
    return weights.last - weights.first;
  }

  static double average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static String money(double n) {
    final abs = n.abs();
    final whole = abs.truncate();
    final cents = ((abs - whole) * 100).round().clamp(0, 99);
    final body = '\$$whole.${cents.toString().padLeft(2, '0')}';
    return n < 0 ? '-$body' : body;
  }

  static String percent(double n) => '${(n * 100).round()}%';

  static String signedLb(double n) {
    final sign = n > 0 ? '+' : '';
    return '$sign${n.toStringAsFixed(1)} lb';
  }

  static String clock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
