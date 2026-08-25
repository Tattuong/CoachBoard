import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/calc/coach_math.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/coach_pdf.dart';
import '../../data/coach_catalog.dart';
import '../../models/coach_models.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coach_ui.dart';

class ClientWorkspaceScreen extends StatefulWidget {
  final String clientId;
  final String? sessionId;
  const ClientWorkspaceScreen({super.key, required this.clientId, this.sessionId});

  @override
  State<ClientWorkspaceScreen> createState() => _ClientWorkspaceScreenState();
}

class _ClientWorkspaceScreenState extends State<ClientWorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late TextEditingController _name;
  late TextEditingController _nick;
  late TextEditingController _notes;
  late TextEditingController _weight;
  String _goal = CoachCatalog.goals.first;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _name = TextEditingController();
    _nick = TextEditingController();
    _notes = TextEditingController();
    _weight = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final board = context.read<CoachProvider>();
    final c = board.clientById(widget.clientId);
    if (c == null) {
      Navigator.pop(context);
      return;
    }
    _name.text = c.name;
    _nick.text = c.nickname;
    _notes.text = c.notes;
    _goal = CoachCatalog.goals.contains(c.goal) ? c.goal : CoachCatalog.goals.first;
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _name.dispose();
    _nick.dispose();
    _notes.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    final board = context.read<CoachProvider>();
    final c = board.clientById(widget.clientId);
    if (c == null) return;
    await board.upsertClient(c.copyWith(name: _name.text.trim().isEmpty ? 'Athlete' : _name.text.trim(), nickname: _nick.text.trim(), goal: _goal, notes: _notes.text.trim()));
  }

  TrainingSession? _session(CoachProvider board) {
    if (widget.sessionId != null) return board.sessionById(widget.sessionId!);
    final live = board.liveSession;
    if (live != null && live.clientId == widget.clientId) return live;
    final list = board.forClient(widget.clientId);
    return list.isEmpty ? null : list.first;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: AppColors.page(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final board = context.watch<CoachProvider>();
    final client = board.clientById(widget.clientId);
    if (client == null) return const SizedBox.shrink();
    final session = _session(board);
    final brand = AppColors.brand(context);
    final muted = AppColors.muted(context);

    return Scaffold(
      backgroundColor: AppColors.page(context),
      appBar: AppBar(
        backgroundColor: AppColors.page(context),
        foregroundColor: AppColors.ink(context),
        title: Column(
          children: [
            Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(AppStrings.t(context, 'workspace'), style: TextStyle(fontSize: 11, color: muted)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await _saveClient();
                await CoachPdf.shareProgress(client: board.clientById(widget.clientId) ?? client, sessions: board.forClient(widget.clientId), attendance: board.attendanceRate);
              } catch (_) {
                if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'exportFailed'), icon: Icons.error_outline);
              }
            },
            icon: Icon(Icons.ios_share_rounded, color: brand),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(text: AppStrings.t(context, 'tabWorkout')),
            Tab(text: AppStrings.t(context, 'tabMeasures')),
            Tab(text: AppStrings.t(context, 'tabNotes')),
            Tab(text: AppStrings.t(context, 'tabHistory')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _workout(board, client, session),
          _measures(board, client),
          _notesTab(),
          _history(board),
        ],
      ),
    );
  }

  Widget _workout(CoachProvider board, Athlete client, TrainingSession? session) {
    final lifts = session?.lifts ?? const <LiftLine>[];
    final elapsed = session?.elapsedSec ?? 0;
    final running = session?.running ?? false;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.brandSoft(context), foregroundColor: AppColors.brand(context), child: Text(client.initials, style: const TextStyle(fontWeight: FontWeight.w900))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  TextField(controller: _name, decoration: InputDecoration(labelText: AppStrings.t(context, 'clientName'), isDense: true)),
                  TextField(controller: _nick, decoration: InputDecoration(labelText: AppStrings.t(context, 'nickname'), isDense: true)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _goal,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'goal')),
          items: [for (final g in CoachCatalog.goals) DropdownMenuItem(value: g, child: Text(g))],
          onChanged: (v) => setState(() => _goal = v ?? _goal),
        ),
        const SizedBox(height: 14),
        Text(session?.title ?? AppStrings.t(context, 'workout'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 8),
        NeonCard(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: Text(AppStrings.t(context, 'exercise'), style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w800))),
                  Expanded(child: Text(AppStrings.t(context, 'sets'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w800))),
                  Expanded(child: Text(AppStrings.t(context, 'reps'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w800))),
                  Expanded(child: Text(AppStrings.t(context, 'weight'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w800))),
                ],
              ),
              Divider(color: AppColors.line(context)),
              if (session == null)
                Text(AppStrings.t(context, 'noSessionLinked'), style: TextStyle(color: AppColors.muted(context)))
              else
                for (var i = 0; i < lifts.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(lifts[i].exercise, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        Expanded(child: Text('${lifts[i].sets}', textAlign: TextAlign.center)),
                        Expanded(child: Text('${lifts[i].reps}', textAlign: TextAlign.center)),
                        Expanded(child: Text('${lifts[i].weightLb.toStringAsFixed(0)} lb', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _RingPainter((elapsed % 3600) / 3600, brand: AppColors.brand(context), track: AppColors.line(context)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(CoachMath.clock(elapsed), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.brand(context))),
                    Text(AppStrings.t(context, 'elapsed'), style: TextStyle(fontSize: 11, color: AppColors.muted(context), letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (session != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => running ? board.pauseTimer() : board.startTimer(session),
                  child: Text(running ? AppStrings.t(context, 'pause') : AppStrings.t(context, 'startTimer')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: board.finishTimer, child: Text(AppStrings.t(context, 'finish')))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: board.resetTimer, child: Text(AppStrings.t(context, 'reset')))),
            ],
          ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saveClient, style: FilledButton.styleFrom(backgroundColor: AppColors.elevated(context), foregroundColor: AppColors.brand(context)), child: Text(AppStrings.t(context, 'save'))),
      ],
    );
  }

  Widget _measures(CoachProvider board, Athlete client) {
    final weights = [for (final m in client.measures) m.weightLb];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(AppStrings.t(context, 'tabMeasures'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 6),
        Text(AppStrings.t(context, 'measureHint'), style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
        const SizedBox(height: 12),
        if (weights.length >= 2) SparkLine(values: weights),
        const SizedBox(height: 8),
        Text(CoachMath.signedLb(CoachMath.weightDelta(weights)), style: TextStyle(color: AppColors.brand(context), fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextField(controller: _weight, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(context, 'weightLb')))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final n = double.tryParse(_weight.text);
                if (n == null) return;
                await board.addMeasure(client, n);
                _weight.clear();
              },
              child: Text(AppStrings.t(context, 'log')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final m in client.measures.reversed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text('${m.weightLb.toStringAsFixed(1)} lb'),
            subtitle: Text(DateFormat.yMMMd().format(m.at)),
          ),
      ],
    );
  }

  Widget _notesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.t(context, 'tabNotes'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          Expanded(
            child: NeonCard(
              child: TextField(
                controller: _notes,
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(hintText: AppStrings.t(context, 'notesHint')),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _saveClient, child: Text(AppStrings.t(context, 'save'))),
        ],
      ),
    );
  }

  Widget _history(CoachProvider board) {
    final list = board.forClient(widget.clientId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(AppStrings.t(context, 'tabHistory'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 8),
        if (list.isEmpty) Text(AppStrings.t(context, 'noSessionsToday'), style: TextStyle(color: AppColors.muted(context))),
        for (final s in list)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(s.attended ? Icons.check_circle : Icons.schedule, color: s.attended ? AppColors.brand(context) : AppColors.muted(context)),
            title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${DateFormat.MMMd().add_jm().format(s.at)} · ${CoachMath.clock(s.elapsedSec)}'),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  final Color brand;
  final Color track;
  const _RingPainter(this.t, {required this.brand, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final fg = Paint()
      ..color = brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -1.57, 6.2832 * t.clamp(0.05, 1), false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.brand != brand || oldDelegate.track != track;
}
