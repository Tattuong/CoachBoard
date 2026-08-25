import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/coach_models.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coach_ui.dart';
import 'client_workspace_screen.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<CoachProvider>();
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'navClients'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(AppStrings.t(context, 'swipeToDelete'), style: TextStyle(color: AppColors.muted(context), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (board.clients.length >= board.clientCap) {
                      AppToast.show(context, title: AppStrings.t(context, 'clientCap'), icon: Icons.lock_rounded);
                      return;
                    }
                    final id = board.newId('c');
                    await board.upsertClient(Athlete(id: id, name: 'New athlete'));
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ClientWorkspaceScreen(clientId: id)));
                    }
                  },
                  icon: Icon(Icons.person_add_alt_1_rounded, color: AppColors.brand(context)),
                ),
              ],
            ),
          ),
          Expanded(
            child: board.clients.isEmpty
                ? Center(child: Text(AppStrings.t(context, 'noClients'), style: TextStyle(color: AppColors.muted(context))))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: board.clients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = board.clients[i];
                      return Dismissible(
                        key: ValueKey(c.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(AppStrings.t(ctx, 'deleteClientTitle')),
                                  content: Text(AppStrings.t(ctx, 'deleteClientConfirm', {'name': c.name})),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(AppStrings.t(ctx, 'cancel')),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(AppStrings.t(ctx, 'delete')),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) => board.deleteClient(c.id),
                        child: NeonCard(
                          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ClientWorkspaceScreen(clientId: c.id))),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: AppColors.brandSoft(context), foregroundColor: AppColors.brand(context), child: Text(c.initials, style: const TextStyle(fontWeight: FontWeight.w900))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(c.goal, style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppColors.muted(context)),
                            ],
                          ),
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
