import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';
import '../providers/shop_provider.dart';
import 'coin_purchase_sheet.dart';

enum CoinChipVariant { standard, header }

class CoinBalanceChip extends StatefulWidget {
  final VoidCallback? onTap;
  final CoinChipVariant variant;
  final bool vipStyle;

  const CoinBalanceChip({
    super.key,
    this.onTap,
    this.variant = CoinChipVariant.standard,
    this.vipStyle = false,
  });

  @override
  State<CoinBalanceChip> createState() => _CoinBalanceChipState();
}

class _CoinBalanceChipState extends State<CoinBalanceChip> with SingleTickerProviderStateMixin {
  ShopProvider? _shop;
  int _lastCoins = 0;
  int? _delta;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shop = context.read<ShopProvider>();
    if (_shop != shop) {
      _shop?.removeListener(_onShopChanged);
      _shop = shop;
      _lastCoins = shop.coins;
      _shop!.addListener(_onShopChanged);
    }
  }

  @override
  void dispose() {
    _shop?.removeListener(_onShopChanged);
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onShopChanged() {
    final shop = _shop;
    if (shop == null || !mounted) return;

    final gained = shop.coins - _lastCoins;
    if (gained > 0) {
      setState(() => _delta = gained);
      _pulseCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _delta = null);
      });
    }
    _lastCoins = shop.coins;
  }

  @override
  Widget build(BuildContext context) {
    final coins = context.select<ShopProvider, int>((s) => s.coins);
    final ftr = context.ftrTheme;
    final header = widget.variant == CoinChipVariant.header;
    final vip = widget.vipStyle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap ?? () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(vip && header ? 4 : (header ? 12 : 20)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                height: header ? 34 : 36,
                padding: EdgeInsets.symmetric(horizontal: header ? 10 : 12),
                alignment: Alignment.center,
                decoration: vip && header
                    ? BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ftr.primary.withValues(alpha: 0.55)),
                      )
                    : ftr.coinChip(header: header),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      color: vip && header
                          ? ftr.primaryLight
                          : (ftr.isPremium ? ftr.glowColor : ftr.primary),
                      size: header ? 13 : 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$coins',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: vip && header ? AppColors.darkInk : AppColors.ink(context),
                        fontSize: header ? 13 : 14,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_delta != null)
              Positioned(
                top: -10,
                right: -4,
                child: _CoinDeltaBadge(amount: _delta!),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoinDeltaBadge extends StatelessWidget {
  final int amount;

  const _CoinDeltaBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, -8 * value),
        child: Opacity(opacity: (1 - value * 0.15).clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: AppColors.success.withValues(alpha: 0.4), blurRadius: 8),
          ],
        ),
        child: Text(
          '+$amount',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
