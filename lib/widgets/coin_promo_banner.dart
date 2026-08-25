import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../core/navigation/app_navigator.dart';
import '../providers/shop_provider.dart';
import 'app_ui.dart';
import 'coin_purchase_sheet.dart';

/// Promo block — use [compact] on Home, full layout in Shop.
class CoinPromoBanner extends StatefulWidget {
  final bool compact;
  final bool hideShopButton;
  final bool vipStyle;

  const CoinPromoBanner({
    super.key,
    this.compact = false,
    this.hideShopButton = false,
    this.vipStyle = false,
  });

  @override
  State<CoinPromoBanner> createState() => _CoinPromoBannerState();
}

class _CoinPromoBannerState extends State<CoinPromoBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _CompactPromoBanner(
        expanded: _expanded,
        hideShopButton: widget.hideShopButton,
        onToggle: () => setState(() => _expanded = !_expanded),
      );
    }
    return _FullPromoBanner(hideShopButton: widget.hideShopButton, vipStyle: widget.vipStyle);
  }
}

class _CompactPromoBanner extends StatelessWidget {
  final bool expanded;
  final bool hideShopButton;
  final VoidCallback onToggle;

  const _CompactPromoBanner({
    required this.expanded,
    required this.hideShopButton,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.elevated(context), AppColors.card(context)],
              ),
              border: Border.all(color: AppColors.coin.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.coin, AppColors.coin.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t(context, 'promoCompactTitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelBold(size: 13, color: AppColors.ink(context)),
                            ),
                            Text(
                              AppStrings.t(context, 'promoHotDealDesc', {
                                'pack': shop.weeklyHotDealPackNumber.toString(),
                                'percent': IapConstants.weeklyDealBonusPercent.toString(),
                              }),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
                            ),
                          ],
                        ),
                      ),
                      if (shop.firstPurchaseBonusAvailable)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.t(context, 'firstPurchaseBadge'),
                              style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      if (!shop.isBillingDisabled)
                        Material(
                          color: AppColors.coin,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => CoinPurchaseSheet.show(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              child: Text(
                                AppStrings.t(context, 'promoBuyShort'),
                                style: const TextStyle(color: AppColors.onGold, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.coin, size: 20),
                    ],
                  ),
                ),
                  if (expanded && !hideShopButton) ...[
                    Divider(height: 1, color: AppColors.coin.withValues(alpha: 0.15)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: _UnlockProgress(shop: shop, dense: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () => AppTabs.goShop(),
                              icon: const Icon(Icons.storefront_outlined, size: 16),
                              label: Text(AppStrings.t(context, 'navShop'), style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (expanded) ...[
                    Divider(height: 1, color: AppColors.coin.withValues(alpha: 0.15)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: _UnlockProgress(shop: shop, dense: true),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullPromoBanner extends StatelessWidget {
  final bool hideShopButton;
  final bool vipStyle;

  const _FullPromoBanner({this.hideShopButton = false, this.vipStyle = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final premium = vipStyle;

    return Padding(
      padding: EdgeInsets.fromLTRB(hideShopButton || premium ? 0 : 16, hideShopButton || premium ? 0 : 12, hideShopButton || premium ? 0 : 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: premium
              ? AppColors.shopVipHeroGradient
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.lightPrimaryTint, AppColors.lightWarmTint],
                ),
          border: Border.all(
            color: premium ? AppColors.brand(context).withValues(alpha: 0.4) : AppColors.coin.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: premium ? null : null,
                    color: premium ? Colors.transparent : AppColors.coin.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(premium ? 2 : 8),
                    border: premium ? Border.all(color: AppColors.brand(context).withValues(alpha: 0.55)) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        premium ? Icons.auto_awesome_outlined : Icons.local_fire_department_rounded,
                        color: premium ? AppColors.brand(context) : AppColors.coin,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.t(context, 'promoHotDeal'),
                        style: TextStyle(
                          color: premium ? AppColors.brand(context) : AppColors.coin,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: premium ? 1.1 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (shop.firstPurchaseBonusAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: premium ? 0.2 : 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppStrings.t(context, 'firstPurchaseBadge'),
                      style: TextStyle(
                        color: premium ? AppColors.error.withValues(alpha: 0.85) : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.t(context, 'promoHotDealDesc', {
                'pack': shop.weeklyHotDealPackNumber.toString(),
                'percent': IapConstants.weeklyDealBonusPercent.toString(),
              }),
              style: TextStyle(
                color: premium ? AppColors.darkInk : AppColors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            _UnlockProgress(shop: shop, light: premium),
            const SizedBox(height: 12),
            if (!shop.isBillingDisabled)
              if (hideShopButton)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.brand(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => CoinPurchaseSheet.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            AppStrings.t(context, 'promoBuyNow'),
                            style: const TextStyle(color: AppColors.onGold, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => CoinPurchaseSheet.show(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.coin,
                          foregroundColor: AppColors.onGold,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(AppStrings.t(context, 'promoBuyNow'), style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => AppTabs.goShop(),
                        child: Text(AppStrings.t(context, 'navShop'), style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _UnlockProgress extends StatelessWidget {
  final ShopProvider shop;
  final bool dense;
  final bool light;

  const _UnlockProgress({required this.shop, this.dense = false, this.light = false});

  @override
  Widget build(BuildContext context) {
    final next = shop.nextUnlockItem;
    if (next == null) return const SizedBox.shrink();

    final ready = shop.hasAffordableUnlock;
    final progressLabel = ready
        ? AppStrings.t(context, 'promoUnlockReady')
        : AppStrings.t(context, 'promoUnlockRemaining', {'count': shop.coinsToNextUnlock.toString()});

    return Padding(
      padding: EdgeInsets.only(top: dense ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progressLabel,
            style: TextStyle(
              color: light ? Colors.white.withValues(alpha: 0.65) : AppColors.onSurfaceVariant,
              fontSize: dense ? 10 : 11,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: shop.unlockProgress,
              minHeight: dense ? 5 : 7,
              backgroundColor: light ? Colors.white.withValues(alpha: 0.12) : Colors.white,
              color: light ? AppColors.coin : AppColors.coin,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact promo header inside the coin purchase bottom sheet.
class CoinPurchasePromoHeader extends StatelessWidget {
  const CoinPurchasePromoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final hotIndex = shop.weeklyHotDealPackIndex;
    final total = shop.effectiveCoinsForPackIndex(hotIndex);
    final bonus = total - IapConstants.coinPackAmounts[hotIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.coin.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.coin.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.coin, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.t(context, 'purchasePromoDesc', {
                'pack': shop.weeklyHotDealPackNumber.toString(),
                'coins': total.toString(),
                'bonus': bonus.toString(),
              }),
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
          if (shop.firstPurchaseBonusAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppStrings.t(context, 'firstPurchaseBadge'),
                style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
