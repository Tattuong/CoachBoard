import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/services/sound_service.dart';
import '../../models/app_theme_preset.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'business_screen.dart';
import 'clients_screen.dart';
import 'dashboard_screen.dart';
import 'programs_screen.dart';
import 'sessions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    AppTabs.index.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ShopProvider>().claimDailyReward();
    });
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppTabs.index.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = AppTabs.index.value.clamp(0, 4);
    final ftr = context.ftrTheme;
    return FtrScaffold(
      extendBody: false,
      body: switch (index) {
        0 => const DashboardScreen(),
        1 => const ClientsScreen(),
        2 => const SessionsScreen(),
        3 => const ProgramsScreen(),
        _ => const BusinessScreen(),
      },
      bottomNavigationBar: Container(
        color: ftr.navBar,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(Icons.dashboard_outlined, AppStrings.t(context, 'navDash'), 0, AppTabs.goDash),
                _item(Icons.groups_outlined, AppStrings.t(context, 'navClients'), 1, AppTabs.goClients),
                _item(Icons.event_outlined, AppStrings.t(context, 'navSessions'), 2, AppTabs.goSessions),
                _item(Icons.fitness_center, AppStrings.t(context, 'navPrograms'), 3, AppTabs.goPrograms),
                _item(Icons.pie_chart_outline, AppStrings.t(context, 'navBusiness'), 4, AppTabs.goBusiness),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int i, VoidCallback onTap) {
    final selected = AppTabs.index.value == i;
    final ftr = context.ftrTheme;
    final color = selected ? ftr.navActive : AppColors.navInactive;
    return InkWell(
      onTap: () {
        SoundService.instance.tap();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
