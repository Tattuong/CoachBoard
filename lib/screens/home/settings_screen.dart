import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/services/sound_service.dart';
import '../../models/app_theme_preset.dart';
import '../../models/shop_item.dart';
import '../../providers/coach_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final shop = context.watch<ShopProvider>();
    final board = context.watch<CoachProvider>();
    final ink = AppColors.ink(context);
    final accent = context.lumenAccent;
    final muted = AppColors.muted(context);

    final content = SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            children: [
              Row(
                children: [
                  if (!embedded)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: ink),
                    ),
                  Expanded(
                    child: Text(
                      AppStrings.t(context, embedded ? 'navMore' : 'settings'),
                      style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: accent, height: 1.05),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 22),
                child: Text(
                  AppStrings.t(context, 'jobsThisWeek', {'n': '${board.clients.length}'}),
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: muted),
                ),
              ),
              _SectionLabel(AppStrings.t(context, 'appearance')),
              _Group(
                children: [
                  _Row(
                    icon: Icons.palette_outlined,
                    title: AppStrings.t(context, 'currentLook'),
                    subtitle: _lookName(context, shop),
                  ),
                  if (!shop.isDefaultLook)
                    _Row(
                      icon: Icons.restart_alt_rounded,
                      title: AppStrings.t(context, 'resetDefault'),
                      subtitle: AppStrings.t(context, 'resetDefaultDesc'),
                      trailing: Icon(Icons.chevron_right_rounded, color: muted),
                      onTap: () async {
                        SoundService.instance.tap();
                        await shop.resetLookToDefault();
                        if (context.mounted) {
                          AppToast.show(context, title: AppStrings.t(context, 'lookResetDone'));
                        }
                      },
                    ),
                  _Row(
                    icon: Icons.dark_mode_outlined,
                    title: AppStrings.t(context, 'darkMode'),
                    trailing: Switch(value: theme.isDarkMode, onChanged: (_) => theme.toggleTheme()),
                  ),
                  _Row(
                    icon: Icons.storefront_outlined,
                    title: AppStrings.t(context, 'shop'),
                    trailing: Icon(Icons.chevron_right_rounded, color: muted),
                    onTap: () {
                      if (!embedded) Navigator.pop(context);
                      AppTabs.goShop();
                    },
                  ),
                ],
              ),
              _SectionLabel(AppStrings.t(context, 'about')),
              _Group(
                children: [
                  _Row(
                    icon: Icons.privacy_tip_outlined,
                    title: AppStrings.t(context, 'privacyPolicy'),
                    trailing: Icon(Icons.chevron_right_rounded, color: muted),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                  _Row(
                    icon: Icons.info_outline_rounded,
                    title: AppStrings.t(context, 'about'),
                    subtitle: AppStrings.t(context, 'version', {'v': '1.0.1'}),
                  ),
                ],
              ),
            ],
          ),
    );

    if (embedded) return ColoredBox(color: AppColors.page(context), child: content);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FtrBackground(child: content),
    );
  }

  String _lookName(BuildContext context, ShopProvider shop) {
    return [
      AppStrings.t(context, ShopCatalog.find(shop.activeThemeId)?.nameKey ?? 'shopThemeDefault'),
      AppStrings.t(context, ShopCatalog.find(shop.activeBackgroundId)?.nameKey ?? 'shopBgDefault'),
      AppStrings.t(context, ShopCatalog.find(shop.activeSkinId)?.nameKey ?? 'shopSkinDefault'),
    ].join(' · ');
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Text(text, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.muted(context))),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Row({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: context.lumenAccent),
      title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted(context))),
      trailing: trailing,
    );
  }
}
