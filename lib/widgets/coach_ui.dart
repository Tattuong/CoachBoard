import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const NeonCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap});

  @override
  Widget build(BuildContext context) {
    final ftr = context.ftrTheme;
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: ftr.surfaceCard(radius: 16),
      child: child,
    );
    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: box);
  }
}

class NeonLabel extends StatelessWidget {
  final String text;
  const NeonLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.brand(context),
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class AttendanceRing extends StatelessWidget {
  final double rate;
  final String caption;
  const AttendanceRing({super.key, required this.rate, required this.caption});

  @override
  Widget build(BuildContext context) {
    final brand = AppColors.brand(context);
    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: CustomPaint(
            painter: _RingPainter(rate.clamp(0, 1), brand: brand, track: AppColors.line(context)),
            child: Center(
              child: Text(
                '${(rate * 100).round()}%',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: brand),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(caption, style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  final Color brand;
  final Color track;
  const _RingPainter(this.t, {required this.brand, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fg = Paint()
      ..color = brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -1.57, 6.2832 * t, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.brand != brand || oldDelegate.track != track;
}

class SparkLine extends StatelessWidget {
  final List<double> values;
  const SparkLine({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(values, AppColors.brand(context))),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 1e-6 ? 1.0 : max - min;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] - min) / span * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => true;
}
