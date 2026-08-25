import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_theme_preset.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_ui.dart';
import 'coin_purchase_sheet.dart';

class CoinEngagementCards extends StatefulWidget {
  final bool salon;

  const CoinEngagementCards({super.key, this.salon = false});

  @override
  State<CoinEngagementCards> createState() => _CoinEngagementCardsState();
}

class _CoinEngagementCardsState extends State<CoinEngagementCards> {
  bool _dailyClaimed = false;
  bool _spinUsed = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final shop = context.read<ShopProvider>();
    final daily = await shop.hasClaimedDailyToday();
    final spin = await shop.hasSpunToday();
    if (mounted) setState(() { _dailyClaimed = daily; _spinUsed = spin; });
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.t(context, 'earnCoins'),
          style: widget.salon
              ? AppTypography.playfair(size: 18, color: AppColors.darkInk)
              : AppTypography.titleLarge().copyWith(fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          AppStrings.t(context, 'earnCoinsDesc'),
          style: TextStyle(
            color: AppColors.muted(context),
            fontSize: 12,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        _EngagementCard(
          salon: widget.salon,
          icon: Icons.calendar_today_outlined,
          title: AppStrings.t(context, 'dailyReward'),
          subtitle: AppStrings.t(context, 'loginStreak', {'days': shop.loginStreak.toString()}),
          buttonLabel: _dailyClaimed ? AppStrings.t(context, 'dailyClaimed') : AppStrings.t(context, 'claimDaily'),
          enabled: !_dailyClaimed,
          color: AppColors.success,
          onTap: () async {
            await shop.claimDailyReward();
            if (context.mounted) _refresh();
          },
        ),
        const SizedBox(height: 8),
        _EngagementCard(
          salon: widget.salon,
          icon: Icons.casino_outlined,
          title: AppStrings.t(context, 'spinWheel'),
          subtitle: AppStrings.t(context, 'spinNow'),
          buttonLabel: _spinUsed ? AppStrings.t(context, 'spinUsed') : AppStrings.t(context, 'spinNow'),
          enabled: !_spinUsed,
          color: AppColors.coin,
          onTap: () async {
            await shop.spinDailyWheel();
            if (context.mounted) _refresh();
          },
        ),
        if (!shop.isBillingDisabled) ...[
          const SizedBox(height: 8),
          _EngagementCard(
            salon: widget.salon,
            icon: Icons.shopping_bag_outlined,
            title: AppStrings.t(context, 'buyCoins'),
            subtitle: AppStrings.t(context, 'buyCoinsDesc'),
            buttonLabel: AppStrings.t(context, 'promoBuyShort'),
            enabled: true,
            color: AppColors.brand(context),
            onTap: () => CoinPurchaseSheet.show(context),
          ),
        ],
      ],
    );
  }
}

class _EngagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;
  final bool salon;

  const _EngagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.enabled,
    required this.color,
    required this.onTap,
    this.salon = false,
  });

  @override
  Widget build(BuildContext context) {
    final ftr = context.ftrTheme;
    final ink = AppColors.ink(context);
    final muted = AppColors.muted(context);
    final accent = color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(salon ? 4 : 14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: salon ? AppColors.salon.withValues(alpha: 0.55) : ftr.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(salon ? 4 : 14),
            border: Border.all(color: salon ? AppColors.salonLine : color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(salon ? 4 : 10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelBold(size: 13, color: ink),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: enabled ? onTap : null,
                style: FilledButton.styleFrom(
                  backgroundColor: enabled ? ftr.primary : ftr.surfaceElevated,
                  foregroundColor: enabled ? AppColors.onBrand(context) : muted,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(salon ? 4 : 20)),
                ),
                child: Text(buttonLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
