import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/calc/coach_math.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coach_ui.dart';
import 'client_workspace_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<CoachProvider>();
    final hour = DateTime.now().hour;
    final hello = hour < 12 ? 'Good morning, Coach!' : hour < 18 ? 'Good afternoon, Coach!' : 'Good evening, Coach!';
    final today = board.sessionsOn(DateTime.now());

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
                icon: Icon(Icons.menu_rounded, color: AppColors.ink(context)),
              ),
              const Expanded(
                child: Text('Dashboard', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const CoinBalanceChip(variant: CoinChipVariant.header),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.brand(context)),
              const SizedBox(width: 6),
              Text(AppStrings.t(context, 'offlineMode'), style: TextStyle(color: AppColors.brand(context), fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(hello, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text('You’ve got a strong day ahead.', style: TextStyle(color: AppColors.muted(context))),
          const SizedBox(height: 14),
          NeonLabel(AppStrings.t(context, 'todaySessions')),
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${today.length} ${AppStrings.t(context, 'sessions')}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.brand(context))),
                if (today.isEmpty)
                  Text(AppStrings.t(context, 'noSessionsToday'), style: TextStyle(color: AppColors.muted(context)))
                else
                  for (final s in today)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text('${DateFormat.jm().format(s.at)}  ${board.clientById(s.clientId)?.name ?? ''}'),
                      subtitle: Text(s.title),
                      trailing: Icon(s.attended ? Icons.check_circle : Icons.circle_outlined, color: s.attended ? AppColors.brand(context) : AppColors.muted(context)),
                      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ClientWorkspaceScreen(clientId: s.clientId, sessionId: s.id))),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'clientCheckins')),
          NeonCard(
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: AppColors.brand(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${board.checkInsToday} ${AppStrings.t(context, 'checkedInToday')}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'programTasks')),
          NeonCard(
            child: Column(
              children: [
                _kv(context, AppStrings.t(context, 'workoutsAssigned'), '${board.programs.fold<int>(0, (s, p) => s + p.days.length)}'),
                _kv(context, AppStrings.t(context, 'progressUpdates'), '${board.clients.where((c) => c.measures.isNotEmpty).length}'),
                _kv(context, AppStrings.t(context, 'notesToReview'), '${board.clients.where((c) => c.notes.isNotEmpty).length}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NeonCard(
                  child: AttendanceRing(
                    rate: board.attendanceRate,
                    caption: '${board.monthAttended}/${board.monthScheduled} ${AppStrings.t(context, 'sessions')}',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'monthlyEarnings'), style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(CoachMath.money(board.collected), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      SparkLine(values: board.monthlyCollectedSeries.where((n) => n > 0).toList().isEmpty ? const [0, 0] : board.monthlyCollectedSeries),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(AppStrings.t(context, 'medicalDisclaimer'), style: TextStyle(color: AppColors.muted(context), fontSize: 11, height: 1.35)),
          TextButton(onPressed: AppTabs.goShop, child: Text(AppStrings.t(context, 'shop'))),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(k, style: TextStyle(color: AppColors.muted(context)))),
            Text(v, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brand(context))),
          ],
        ),
      );
}
