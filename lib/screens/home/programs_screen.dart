import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/coach_catalog.dart';
import '../../models/coach_models.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/coach_ui.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<CoachProvider>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              Expanded(child: Text(AppStrings.t(context, 'navPrograms'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              IconButton(
                onPressed: () => board.upsertProgram(ProgramPlan(id: board.newId('p'), name: 'New program', days: [ProgramDay(name: 'Day 1', lifts: [LiftLine(exercise: CoachCatalog.exercises.first.name)])])),
                icon: Icon(Icons.add_rounded, color: AppColors.brand(context)),
              ),
            ],
          ),
          NeonLabel(AppStrings.t(context, 'programTemplates')),
          if (board.programs.isEmpty) Text(AppStrings.t(context, 'noPrograms'), style: TextStyle(color: AppColors.muted(context))),
          for (final p in board.programs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 6),
                    for (final d in p.days)
                      Text('${d.name} · ${d.lifts.length} ${AppStrings.t(context, 'lifts')}', style: TextStyle(color: AppColors.muted(context), fontSize: 13)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'exerciseLibrary')),
          NeonCard(
            child: Column(
              children: [
                for (final e in CoachCatalog.exercises)
                  ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(e.name), subtitle: Text(e.group, style: TextStyle(color: AppColors.muted(context)))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeonLabel(AppStrings.t(context, 'equipmentLibrary')),
          NeonCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in CoachCatalog.equipment)
                  Chip(label: Text(e.name), backgroundColor: AppColors.brandSoft(context), side: BorderSide.none, labelStyle: TextStyle(color: AppColors.brand(context), fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
