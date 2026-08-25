import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/calc/coach_math.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/services/coach_pdf.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coach_ui.dart';
import 'client_workspace_screen.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<CoachProvider>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(AppStrings.t(context, 'planBusiness'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _tile(context, Icons.fitness_center, AppStrings.t(context, 'programTemplates'), AppTabs.goPrograms),
              _tile(context, Icons.calendar_month_outlined, AppStrings.t(context, 'navSessions'), AppTabs.goSessions),
              _tile(context, Icons.inventory_2_outlined, AppStrings.t(context, 'packages')),
              _tile(context, Icons.account_balance_wallet_outlined, AppStrings.t(context, 'payments')),
              _tile(context, Icons.accessibility_new_rounded, AppStrings.t(context, 'equipmentLibrary'), AppTabs.goPrograms),
              _tile(context, Icons.description_outlined, AppStrings.t(context, 'reports')),
            ],
          ),
          const SizedBox(height: 16),
          NeonLabel(AppStrings.t(context, 'paymentOverview')),
          NeonCard(
            child: Column(
              children: [
                _kv(context, AppStrings.t(context, 'totalCollected'), CoachMath.money(board.collected)),
                _kv(context, AppStrings.t(context, 'pending'), CoachMath.money(board.pending)),
                _kv(context, AppStrings.t(context, 'overdue'), CoachMath.money(board.overdue), color: AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'packages')),
          if (board.packs.isEmpty) Text(AppStrings.t(context, 'noPacks'), style: TextStyle(color: AppColors.muted(context))),
          for (final p in board.packs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeonCard(
                child: Text(
                  '${board.clientById(p.clientId)?.name ?? '—'} · ${p.left}/${p.total} ${AppStrings.t(context, 'sessionsLeft')}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'progressOverview')),
          Row(
            children: [
              Expanded(
                child: NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'weightProgress'), style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w700)),
                      Text(CoachMath.signedLb(board.avgWeightDelta), style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brand(context))),
                      Text(AppStrings.t(context, 'avgChange'), style: TextStyle(fontSize: 11, color: AppColors.muted(context))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeonCard(
                  child: AttendanceRing(rate: board.attendanceRate, caption: '${board.monthAttended}/${board.monthScheduled}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final client = board.clients.isEmpty ? null : board.clients.first;
              if (client == null) return;
              try {
                await CoachPdf.shareProgress(client: client, sessions: board.forClient(client.id), attendance: board.attendanceRate);
              } catch (_) {
                if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'exportFailed'), icon: Icons.error_outline);
              }
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(AppStrings.t(context, 'exportPdf')),
          ),
          const SizedBox(height: 8),
          Text(AppStrings.t(context, 'medicalDisclaimer'), style: TextStyle(color: AppColors.muted(context), fontSize: 11, height: 1.35)),
          if (board.clients.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ClientWorkspaceScreen(clientId: board.clients.first.id))),
              child: Text(AppStrings.t(context, 'openFirstClient')),
            ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, [VoidCallback? onTap]) => NeonCard(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.brand(context)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _kv(BuildContext context, String k, String v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(k, style: TextStyle(color: AppColors.muted(context)))),
            Text(v, style: TextStyle(fontWeight: FontWeight.w900, color: color ?? AppColors.ink(context))),
          ],
        ),
      );
}
