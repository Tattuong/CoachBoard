import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';
import '../models/shop_item.dart';
import '../providers/shop_provider.dart';
import 'circuit_backdrop.dart';

class FtrBackground extends StatelessWidget {
  final Widget child;

  const FtrBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = context.select<ShopProvider, AppBackground>((s) => s.activeBackground);
    final ftr = context.ftrTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customBg = bg.id != ShopCatalog.defaultBackgroundId;
    final gradient = customBg
        ? LinearGradient(
            begin: bg.gradient.begin,
            end: bg.gradient.end,
            colors: bg.gradient.colors
                .map((c) => isDark ? c : Color.lerp(Theme.of(context).scaffoldBackgroundColor, c, 0.22)!)
                .toList(),
            stops: bg.gradient.stops,
          )
        : null;

    return CircuitBackdrop(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (gradient != null) DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          if (ftr.isPremium)
            const _PremiumAura()
          else if (customBg)
            const _PremiumAura(soft: true),
          child,
        ],
      ),
    );
  }
}

class _PremiumAura extends StatelessWidget {
  final bool soft;

  const _PremiumAura({this.soft = false});

  @override
  Widget build(BuildContext context) {
    final ftr = context.ftrTheme;
    final boost = soft ? 0.55 : 1.0;
    return IgnorePointer(
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.85, -1),
              end: const Alignment(1, 0.8),
              colors: [
                ftr.glowColor.withValues(alpha: 0.18 * boost),
                Colors.transparent,
                ftr.primary.withValues(alpha: 0.10 * boost),
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class FtrScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const FtrScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      extendBody: extendBody,
      backgroundColor: scaffoldColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: FtrBackground(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.line(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
