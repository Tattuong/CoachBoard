import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class StepperField extends StatelessWidget {
  final String label;
  final String? suffix;
  final double value;
  final double step;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;

  const StepperField({
    super.key,
    required this.label,
    this.suffix,
    required this.value,
    this.step = 0.1,
    this.min = 0,
    this.max = 10000,
    this.decimals = 2,
    required this.onChanged,
  });

  String get _text {
    if (decimals == 0) return value.round().toString();
    final t = value.toStringAsFixed(decimals);
    return t.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
          const SizedBox(height: 6),
          Row(
            children: [
              _Btn(icon: Icons.remove, onTap: () => onChanged((value - step).clamp(min, max))),
              Expanded(
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line(context)),
                  ),
                  child: Text(
                    suffix == null ? _text : '$_text $suffix',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: ink),
                  ),
                ),
              ),
              _Btn(icon: Icons.add, onTap: () => onChanged((value + step).clamp(min, max))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppColors.brandSoft(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 44, height: 44, child: Icon(icon, color: AppColors.brand(context), size: 20)),
        ),
      ),
    );
  }
}

class PercentChips extends StatelessWidget {
  final String label;
  final double value;
  final List<double> options;
  final String suffix;
  final ValueChanged<double> onChanged;

  const PercentChips({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.suffix = '%',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text('${o == o.roundToDouble() ? o.toInt() : o} $suffix'),
                  selected: (value - o).abs() < 0.01,
                  onSelected: (_) => onChanged(o),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
