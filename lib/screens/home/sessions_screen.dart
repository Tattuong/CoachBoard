import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/coach_catalog.dart';
import '../../models/coach_models.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/coach_ui.dart';
import 'client_workspace_screen.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<CoachProvider>();
    final list = [...board.sessions]..sort((a, b) => a.at.compareTo(b.at));
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text(AppStrings.t(context, 'navSessions'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                IconButton(
                  onPressed: () async {
                    if (board.clients.isEmpty) return;
                    final client = board.clients.first;
                    await board.upsertSession(
                      TrainingSession(
                        id: board.newId('s'),
                        clientId: client.id,
                        at: DateTime.now().add(const Duration(hours: 1)),
                        title: 'Session',
                        lifts: [LiftLine(exercise: CoachCatalog.exercises.first.name)],
                      ),
                      reward: true,
                    );
                  },
                  icon: Icon(Icons.add_rounded, color: AppColors.brand(context)),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(AppStrings.t(context, 'noSessionsToday'), style: TextStyle(color: AppColors.muted(context))))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final s = list[i];
                      final name = board.clientById(s.clientId)?.name ?? '—';
                      return NeonCard(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => board.toggleAttend(s),
                              icon: Icon(s.attended ? Icons.check_circle : Icons.circle_outlined, color: s.attended ? AppColors.brand(context) : AppColors.muted(context)),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ClientWorkspaceScreen(clientId: s.clientId, sessionId: s.id))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$name · ${s.title}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(DateFormat.MMMd().add_jm().format(s.at), style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
