import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../models/app_theme_preset.dart';
import '../../models/shop_item.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';

enum ShopRewardsTab { themes, backgrounds, skins, features }

class ShopScreen extends StatefulWidget {
  final ShopRewardsTab? initialTab;

  const ShopScreen({super.key, this.initialTab});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late ShopRewardsTab _tab;

  static const _aisles = [
    (ShopRewardsTab.themes, 'shopMenuThemes', Icons.eco_outlined),
    (ShopRewardsTab.backgrounds, 'shopMenuBackgrounds', Icons.landscape_outlined),
    (ShopRewardsTab.skins, 'shopMenuSkins', Icons.layers_outlined),
    (ShopRewardsTab.features, 'shopMenuFeatures', Icons.handyman_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab ??
        (AppTabs.shopFeatures.value ? ShopRewardsTab.features : ShopRewardsTab.themes);
    AppTabs.shopFeatures.addListener(_onShopTab);
  }

  void _onShopTab() {
    if (!mounted || !AppTabs.shopFeatures.value) return;
    setState(() => _tab = ShopRewardsTab.features);
  }

  @override
  void dispose() {
    AppTabs.shopFeatures.removeListener(_onShopTab);
    super.dispose();
  }

  List<ShopItem> get _items {
    return ShopCatalog.items.where((item) {
      return switch (_tab) {
        ShopRewardsTab.themes => item.category == ShopItemCategory.themes,
        ShopRewardsTab.backgrounds => item.category == ShopItemCategory.backgrounds,
        ShopRewardsTab.skins => item.category == ShopItemCategory.skins,
        ShopRewardsTab.features =>
          item.category == ShopItemCategory.features || item.category == ShopItemCategory.premium,
      };
    }).toList();
  }

  String get _rackTitle {
    return switch (_tab) {
      ShopRewardsTab.themes => AppStrings.t(context, 'shopSeedRack'),
      ShopRewardsTab.backgrounds => AppStrings.t(context, 'shopPlotBeds'),
      ShopRewardsTab.skins => AppStrings.t(context, 'shopCardStyles'),
      ShopRewardsTab.features => AppStrings.t(context, 'shopToolshed'),
    };
  }

  bool _canResetTab(ShopProvider shop) {
    return switch (_tab) {
      ShopRewardsTab.themes => shop.activeThemeId != ShopCatalog.defaultThemeId,
      ShopRewardsTab.backgrounds => shop.activeBackgroundId != ShopCatalog.defaultBackgroundId,
      ShopRewardsTab.skins => shop.activeSkinId != ShopCatalog.defaultSkinId,
      ShopRewardsTab.features => false,
    };
  }

  ShopItem? _growing(ShopProvider shop) {
    return switch (_tab) {
      ShopRewardsTab.themes => ShopCatalog.find(shop.activeThemeId),
      ShopRewardsTab.backgrounds => ShopCatalog.find(shop.activeBackgroundId),
      ShopRewardsTab.skins => ShopCatalog.find(shop.activeSkinId),
      ShopRewardsTab.features => null,
    };
  }

  Future<void> _resetTab(BuildContext context, ShopProvider shop) async {
    switch (_tab) {
      case ShopRewardsTab.themes:
        await shop.resetThemeToDefault();
      case ShopRewardsTab.backgrounds:
        await shop.resetBackgroundToDefault();
      case ShopRewardsTab.skins:
        await shop.resetSkinToDefault();
      case ShopRewardsTab.features:
        return;
    }
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'lookResetDone'));
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final items = _items;
    final growing = _growing(shop);
    final brand = AppColors.brand(context);
    final ink = AppColors.ink(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FtrBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Icon(Icons.arrow_back_rounded, color: ink),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.t(context, 'shop'),
                            style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: brand, height: 1),
                          ),
                          Text(
                            AppStrings.t(context, 'shopTagline'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted(context)),
                          ),
                        ],
                      ),
                    ),
                    CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _HarvestStrip(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    for (final aisle in _aisles) ...[
                      if (aisle != _aisles.first) const SizedBox(width: 8),
                      Expanded(
                        child: _AisleTile(
                          label: AppStrings.t(context, aisle.$2),
                          icon: aisle.$3,
                          selected: _tab == aisle.$1,
                          onTap: () => setState(() => _tab = aisle.$1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  child: _AisleBody(
                    key: ValueKey(_tab),
                    tab: _tab,
                    shop: shop,
                    items: items,
                    growing: growing,
                    rackTitle: _rackTitle,
                    canReset: _canResetTab(shop),
                    onReset: () => _resetTab(context, shop),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AisleBody extends StatelessWidget {
  final ShopRewardsTab tab;
  final ShopProvider shop;
  final List<ShopItem> items;
  final ShopItem? growing;
  final String rackTitle;
  final bool canReset;
  final VoidCallback onReset;

  const _AisleBody({
    super.key,
    required this.tab,
    required this.shop,
    required this.items,
    required this.growing,
    required this.rackTitle,
    required this.canReset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        if (growing != null) ...[
          _RackLabel(AppStrings.t(context, 'shopNowGrowing'), trailing: canReset ? AppStrings.t(context, 'useDefault') : null, onTrailing: canReset ? onReset : null),
          const SizedBox(height: 8),
          _HeroPlot(item: growing!, shop: shop),
          const SizedBox(height: 20),
        ],
        _RackLabel(rackTitle, trailing: growing == null && canReset ? AppStrings.t(context, 'useDefault') : null, onTrailing: growing == null && canReset ? onReset : null),
        const SizedBox(height: 10),
        if (tab == ShopRewardsTab.features)
          ...[
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ToolRow(item: item, shop: shop),
              ),
          ]
        else if (tab == ShopRewardsTab.backgrounds)
          ...[
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlotRow(item: item, shop: shop),
              ),
          ]
        else
          SizedBox(
            height: 236,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _SeedPacket(item: items[i], shop: shop),
            ),
          ),
        if (!shop.isBillingDisabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: shop.restorePurchases,
              style: TextButton.styleFrom(foregroundColor: AppColors.muted(context)),
              child: Text(AppStrings.t(context, 'restorePurchases'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

class _HarvestStrip extends StatefulWidget {
  const _HarvestStrip();

  @override
  State<_HarvestStrip> createState() => _HarvestStripState();
}

class _HarvestStripState extends State<_HarvestStrip> {
  bool _dailyClaimed = false;
  bool _spinUsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final shop = context.read<ShopProvider>();
    final daily = await shop.hasClaimedDailyToday();
    final spin = await shop.hasSpunToday();
    if (!mounted) return;
    setState(() {
      _dailyClaimed = daily;
      _spinUsed = spin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final brand = AppColors.brand(context);
    return Material(
      color: brand,
      shape: const RoundedRectangleBorder(borderRadius: _Beds.banner),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t(context, 'shopDailyHarvest').toUpperCase(),
              style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Stamp(
                    icon: Icons.wb_sunny_outlined,
                    label: _dailyClaimed ? AppStrings.t(context, 'dailyClaimed') : AppStrings.t(context, 'claimDaily'),
                    dim: _dailyClaimed,
                    onTap: _dailyClaimed
                        ? null
                        : () async {
                            await shop.claimDailyReward();
                            if (context.mounted) _refresh();
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Stamp(
                    icon: Icons.casino_outlined,
                    label: _spinUsed ? AppStrings.t(context, 'dailyClaimed') : AppStrings.t(context, 'spinNow'),
                    dim: _spinUsed,
                    onTap: _spinUsed
                        ? null
                        : () async {
                            await shop.spinDailyWheel();
                            if (context.mounted) _refresh();
                          },
                  ),
                ),
                if (!shop.isBillingDisabled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Stamp(
                      icon: Icons.savings_outlined,
                      label: AppStrings.t(context, 'shopPacks'),
                      dim: false,
                      onTap: () => CoinPurchaseSheet.show(context),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dim;
  final VoidCallback? onTap;

  const _Stamp({required this.icon, required this.label, required this.dim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: dim ? 0.12 : 0.18),
      shape: const RoundedRectangleBorder(borderRadius: _Beds.stamp),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            children: [
              Icon(icon, size: 18, color: Colors.white.withValues(alpha: dim ? 0.55 : 1)),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: dim ? 0.55 : 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AisleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AisleTile({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brand = AppColors.brand(context);
    return Material(
      color: selected ? brand : AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: _Beds.stamp,
        side: BorderSide(color: selected ? brand : AppColors.line(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 18, color: selected ? context.lumenOnAccent : brand),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected ? context.lumenOnAccent : AppColors.ink(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RackLabel extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;

  const _RackLabel(this.title, {this.trailing, this.onTrailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brand(context), letterSpacing: 1.1),
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTrailing,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(trailing!, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
      ],
    );
  }
}

class _Beds {
  static const banner = BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(26),
    bottomLeft: Radius.circular(26),
    bottomRight: Radius.circular(8),
  );

  static const stamp = BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(14),
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(6),
  );

  static const packet = BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(28),
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(8),
  );
}

class _HeroPlot extends StatelessWidget {
  final ShopItem item;
  final ShopProvider shop;

  const _HeroPlot({required this.item, required this.shop});

  @override
  Widget build(BuildContext context) {
    final look = _Look.of(context, item);
    return Material(
      color: look.fill,
      shape: const RoundedRectangleBorder(borderRadius: _Beds.banner),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: look.canTap(shop, item) ? () => _ShopActions.apply(context, shop, item) : null,
        child: SizedBox(
          height: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (look.gradient != null) DecoratedBox(decoration: BoxDecoration(gradient: look.gradient)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC1A120C)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Swatches(look.swatches),
                    const Spacer(),
                    Text(
                      AppStrings.t(context, item.nameKey),
                      style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(context, item.descKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xE6FFF8EC)),
                    ),
                    const SizedBox(height: 10),
                    _PriceTag(item: item, shop: shop, onDark: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeedPacket extends StatelessWidget {
  final ShopItem item;
  final ShopProvider shop;

  const _SeedPacket({required this.item, required this.shop});

  @override
  Widget build(BuildContext context) {
    final look = _Look.of(context, item);
    final active = _ShopActions.isActive(shop, item);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _Beds.packet,
        boxShadow: [
          BoxShadow(color: (look.glow ?? const Color(0xFF3A2410)).withValues(alpha: 0.16), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: _Beds.packet, side: BorderSide(color: active ? AppColors.brand(context) : AppColors.line(context), width: active ? 1.6 : 1)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: look.canTap(shop, item) ? () => _ShopActions.apply(context, shop, item) : null,
          child: SizedBox(
            width: 168,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 118,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: look.fill, gradient: look.gradient),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Align(alignment: Alignment.topLeft, child: _Swatches(look.swatches)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t(context, item.nameKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink(context)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.t(context, item.descKey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(fontSize: 11, height: 1.25, fontWeight: FontWeight.w600, color: AppColors.muted(context)),
                        ),
                        const Spacer(),
                        _PriceTag(item: item, shop: shop, onDark: false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlotRow extends StatelessWidget {
  final ShopItem item;
  final ShopProvider shop;

  const _PlotRow({required this.item, required this.shop});

  @override
  Widget build(BuildContext context) {
    final look = _Look.of(context, item);
    return Material(
      color: look.fill,
      shape: const RoundedRectangleBorder(borderRadius: _Beds.banner),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: look.canTap(shop, item) ? () => _ShopActions.apply(context, shop, item) : null,
        child: SizedBox(
          height: 92,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (look.gradient != null) DecoratedBox(decoration: BoxDecoration(gradient: look.gradient)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x991A120C), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.t(context, item.nameKey), style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(AppStrings.t(context, item.descKey), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xE6FFF8EC))),
                        ],
                      ),
                    ),
                    _PriceTag(item: item, shop: shop, onDark: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final ShopItem item;
  final ShopProvider shop;

  const _ToolRow({required this.item, required this.shop});

  @override
  Widget build(BuildContext context) {
    final owned = shop.ownsItem(item.id);
    final brand = AppColors.brand(context);
    return Material(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(borderRadius: _Beds.banner, side: BorderSide(color: AppColors.line(context))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: owned ? null : () => _ShopActions.buy(context, shop, item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.brandSoft(context), borderRadius: _Beds.stamp),
                child: Icon(item.icon, color: brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(context, item.nameKey), style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink(context))),
                    Text(AppStrings.t(context, item.descKey), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted(context))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PriceTag(item: item, shop: shop, onDark: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  final List<Color> colors;
  const _Swatches(this.colors);

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (final c in colors)
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 1.2),
            ),
          ),
      ],
    );
  }
}

class _PriceTag extends StatelessWidget {
  final ShopItem item;
  final ShopProvider shop;
  final bool onDark;

  const _PriceTag({required this.item, required this.shop, required this.onDark});

  @override
  Widget build(BuildContext context) {
    final owned = shop.ownsItem(item.id);
    final active = _ShopActions.isActive(shop, item);
    final label = !owned
        ? '${item.price}'
        : active
            ? AppStrings.t(context, 'active')
            : _ShopActions.canApply(item)
                ? AppStrings.t(context, 'apply')
                : AppStrings.t(context, 'unlocked');
    final brand = AppColors.brand(context);

    return Material(
      color: owned ? (onDark ? Colors.white24 : AppColors.brandSoft(context)) : (onDark ? Colors.white : Colors.white),
      shape: const RoundedRectangleBorder(borderRadius: _Beds.stamp),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: shop.isPurchasing
            ? null
            : () {
                if (!owned) {
                  _ShopActions.buy(context, shop, item);
                } else if (_ShopActions.canApply(item) && !active) {
                  _ShopActions.apply(context, shop, item);
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: onDark && owned ? Colors.white : brand,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _Look {
  final Color fill;
  final LinearGradient? gradient;
  final Color? glow;
  final List<Color> swatches;

  const _Look({required this.fill, this.gradient, this.glow, this.swatches = const []});

  bool canTap(ShopProvider shop, ShopItem item) =>
      shop.ownsItem(item.id) && _ShopActions.canApply(item) && !_ShopActions.isActive(shop, item);

  static _Look of(BuildContext context, ShopItem item) {
    if (item.type == ShopItemType.theme) {
      final preset = AppThemePresets.get(item.id);
      return _Look(
        fill: preset.shopPreviewGradient.colors.first,
        gradient: preset.shopPreviewGradient,
        glow: preset.glowColor,
        swatches: [preset.primary, preset.glowColor, preset.primaryLight],
      );
    }
    if (item.type == ShopItemType.background) {
      final bg = AppBackground.get(item.id);
      return _Look(fill: bg.gradient.colors.first, gradient: bg.gradient, glow: bg.gradient.colors.last);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final papers = isDark
        ? const [Color(0xFF262830), Color(0xFF1E2430), Color(0xFF24201C), Color(0xFF1C2420)]
        : const [Color(0xFFFFFDF9), Color(0xFFF4EFE6), Color(0xFFE8EEF8), Color(0xFFEEF6F0)];
    return _Look(fill: papers[item.id.hashCode.abs() % papers.length], glow: AppColors.brand(context));
  }
}

class _ShopActions {
  static bool isActive(ShopProvider shop, ShopItem item) {
    return switch (item.type) {
      ShopItemType.theme => shop.activeThemeId == item.id,
      ShopItemType.background => shop.activeBackgroundId == item.id,
      ShopItemType.skin => shop.activeSkinId == item.id,
      _ => false,
    };
  }

  static bool canApply(ShopItem item) =>
      item.type == ShopItemType.theme || item.type == ShopItemType.background || item.type == ShopItemType.skin;

  static Future<void> apply(BuildContext context, ShopProvider shop, ShopItem item) async {
    switch (item.type) {
      case ShopItemType.theme:
        await shop.selectTheme(item.id);
      case ShopItemType.background:
        await shop.selectBackground(item.id);
      case ShopItemType.skin:
        await shop.selectSkin(item.id);
      default:
        break;
    }
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'applied'));
  }

  static void buy(BuildContext context, ShopProvider shop, ShopItem item) {
    final result = shop.buyWithCoins(item.id);
    switch (result) {
      case ShopPurchaseResult.success:
        AppToast.show(context, title: AppStrings.t(context, item.type == ShopItemType.removeAds ? 'removeAdsUnlocked' : 'purchaseSuccess'));
      case ShopPurchaseResult.insufficientCoins:
        AppToast.show(context, title: AppStrings.t(context, 'insufficientCoins'));
        CoinPurchaseSheet.show(context);
      case ShopPurchaseResult.alreadyOwned:
        AppToast.show(context, title: AppStrings.t(context, 'alreadyOwned'));
      default:
        AppToast.show(context, title: AppStrings.t(context, 'purchaseFailed'));
    }
  }
}
