import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/calc/coach_math.dart';
import '../core/services/storage_service.dart';
import '../data/coach_catalog.dart';
import '../models/coach_models.dart';
import 'shop_provider.dart';

class CoachProvider extends ChangeNotifier {
  static const _dataKey = 'cb_board';
  static const _onboardKey = 'cb_onboarding_done';

  ShopProvider? _shop;
  Timer? _tick;

  bool onboardingComplete = false;
  List<Athlete> clients = [];
  List<TrainingSession> sessions = [];
  List<ProgramPlan> programs = [];
  List<SessionPack> packs = [];
  List<Payment> payments = [];
  String? activeSessionId;

  bool _initialized = false;

  void bindShop(ShopProvider shop) => _shop = shop;

  int get clientCap => 12 + ((_shop?.hasWideWindow ?? false) ? 12 : 0);
  int get programCap => 6 + ((_shop?.hasBedPack ?? false) ? 8 : 0);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    onboardingComplete = await StorageService.instance.getBool(_onboardKey) ?? false;
    await _load();
    if (clients.isEmpty && sessions.isEmpty) {
      _seed();
      await _save();
    }
    _startTicker();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardKey, true);
    notifyListeners();
  }

  Athlete? clientById(String id) {
    for (final c in clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  TrainingSession? sessionById(String id) {
    for (final s in sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<TrainingSession> sessionsOn(DateTime day) {
    final key = _day(day);
    final list = sessions.where((s) => _day(s.at) == key).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return list;
  }

  List<TrainingSession> forClient(String clientId) {
    final list = sessions.where((s) => s.clientId == clientId).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return list;
  }

  int get checkInsToday => sessionsOn(DateTime.now()).where((s) => s.attended).length;

  int get monthScheduled {
    final now = DateTime.now();
    return sessions.where((s) => s.at.year == now.year && s.at.month == now.month).length;
  }

  int get monthAttended {
    final now = DateTime.now();
    return sessions.where((s) => s.at.year == now.year && s.at.month == now.month && s.attended).length;
  }

  double get attendanceRate => CoachMath.attendanceRate(monthAttended, monthScheduled);

  double get collected =>
      payments.where((p) => p.status == PayStatus.collected).fold(0.0, (s, p) => s + p.amount);
  double get pending =>
      payments.where((p) => p.status == PayStatus.pending).fold(0.0, (s, p) => s + p.amount);
  double get overdue =>
      payments.where((p) => p.status == PayStatus.overdue).fold(0.0, (s, p) => s + p.amount);

  List<double> get monthlyCollectedSeries {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month + 1, 0).day;
    return [
      for (var d = 1; d <= days; d++)
        payments
            .where((p) =>
                p.status == PayStatus.collected &&
                p.at.year == now.year &&
                p.at.month == now.month &&
                p.at.day <= d)
            .fold(0.0, (s, p) => s + p.amount),
    ];
  }

  double get avgWeightDelta {
    final deltas = [
      for (final c in clients)
        if (c.measures.length >= 2) CoachMath.weightDelta([for (final m in c.measures) m.weightLb]),
    ];
    return CoachMath.average(deltas);
  }

  String newId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  Future<bool> upsertClient(Athlete client) async {
    final i = clients.indexWhere((c) => c.id == client.id);
    if (i < 0) {
      if (clients.length >= clientCap) return false;
      clients = [...clients, client];
    } else {
      clients = [...clients]..[i] = client;
    }
    await _persist(reward: i < 0);
    return true;
  }

  Future<void> deleteClient(String id) async {
    clients = clients.where((c) => c.id != id).toList();
    sessions = sessions.where((s) => s.clientId != id).toList();
    packs = packs.where((p) => p.clientId != id).toList();
    payments = payments.where((p) => p.clientId != id).toList();
    await _persist();
  }

  Future<bool> upsertSession(TrainingSession session, {bool reward = false}) async {
    final i = sessions.indexWhere((s) => s.id == session.id);
    if (i < 0) {
      sessions = [...sessions, session];
    } else {
      sessions = [...sessions]..[i] = session;
    }
    await _persist(reward: reward);
    return true;
  }

  Future<void> toggleAttend(TrainingSession session) async {
    await upsertSession(session.copyWith(attended: !session.attended), reward: true);
  }

  Future<void> upsertProgram(ProgramPlan plan) async {
    if (programs.length >= programCap && !programs.any((p) => p.id == plan.id)) return;
    final i = programs.indexWhere((p) => p.id == plan.id);
    if (i < 0) {
      programs = [...programs, plan];
    } else {
      programs = [...programs]..[i] = plan;
    }
    await _persist(reward: true);
  }

  Future<void> upsertPack(SessionPack pack) async {
    final i = packs.indexWhere((p) => p.id == pack.id);
    if (i < 0) {
      packs = [...packs, pack];
    } else {
      packs = [...packs]..[i] = pack;
    }
    await _persist();
  }

  Future<void> upsertPayment(Payment pay) async {
    final i = payments.indexWhere((p) => p.id == pay.id);
    if (i < 0) {
      payments = [...payments, pay];
    } else {
      payments = [...payments]..[i] = pay;
    }
    await _persist();
  }

  Future<void> addMeasure(Athlete client, double weightLb) async {
    final next = client.copyWith(measures: [...client.measures, MeasureLog(at: DateTime.now(), weightLb: weightLb)]);
    await upsertClient(next);
  }

  TrainingSession? get liveSession {
    if (activeSessionId == null) return null;
    return sessionById(activeSessionId!);
  }

  Future<void> startTimer(TrainingSession session) async {
    activeSessionId = session.id;
    await upsertSession(session.copyWith(running: true));
  }

  Future<void> pauseTimer() async {
    final s = liveSession;
    if (s == null) return;
    await upsertSession(s.copyWith(running: false));
  }

  Future<void> resetTimer() async {
    final s = liveSession;
    if (s == null) return;
    await upsertSession(s.copyWith(running: false, elapsedSec: 0));
  }

  Future<void> finishTimer() async {
    final s = liveSession;
    if (s == null) return;
    await upsertSession(s.copyWith(running: false, attended: true));
    activeSessionId = null;
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = liveSession;
      if (s == null || !s.running) return;
      final i = sessions.indexWhere((x) => x.id == s.id);
      if (i < 0) return;
      sessions = [...sessions]..[i] = s.copyWith(elapsedSec: s.elapsedSec + 1);
      notifyListeners();
    });
  }

  Future<void> _persist({bool reward = false}) async {
    await _save();
    if (reward) await _shop?.rewardForJobSave();
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final raw = await StorageService.instance.getData(_dataKey);
      if (raw == null) return;
      clients = [
        for (final c in (raw['clients'] as List? ?? const []))
          if (c is Map) Athlete.fromJson(Map<String, dynamic>.from(c)),
      ];
      sessions = [
        for (final s in (raw['sessions'] as List? ?? const []))
          if (s is Map) TrainingSession.fromJson(Map<String, dynamic>.from(s)),
      ];
      programs = [
        for (final p in (raw['programs'] as List? ?? const []))
          if (p is Map) ProgramPlan.fromJson(Map<String, dynamic>.from(p)),
      ];
      packs = [
        for (final p in (raw['packs'] as List? ?? const []))
          if (p is Map) SessionPack.fromJson(Map<String, dynamic>.from(p)),
      ];
      payments = [
        for (final p in (raw['payments'] as List? ?? const []))
          if (p is Map) Payment.fromJson(Map<String, dynamic>.from(p)),
      ];
      activeSessionId = raw['activeSessionId']?.toString();
    } catch (e) {
      debugPrint('coach load error: $e');
    }
  }

  Future<void> _save() async {
    await StorageService.instance.saveData(_dataKey, {
      'clients': [for (final c in clients) c.toJson()],
      'sessions': [for (final s in sessions) s.toJson()],
      'programs': [for (final p in programs) p.toJson()],
      'packs': [for (final p in packs) p.toJson()],
      'payments': [for (final p in payments) p.toJson()],
      'activeSessionId': activeSessionId,
    });
  }

  String _day(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    clients = [
      Athlete(
        id: 'c-alex',
        name: 'Alex R.',
        nickname: 'Alex',
        goal: 'Build Muscle',
        notes: 'Sleep 7h. Keep bench path tight. Not medical advice — log only.',
        measures: [
          MeasureLog(at: today.subtract(const Duration(days: 28)), weightLb: 178.2),
          MeasureLog(at: today.subtract(const Duration(days: 14)), weightLb: 179.4),
          MeasureLog(at: today.subtract(const Duration(days: 2)), weightLb: 180.6),
        ],
      ),
      const Athlete(id: 'c-mia', name: 'Mia Chen', nickname: 'Mia', goal: 'Get Stronger'),
      const Athlete(id: 'c-jon', name: 'Jordan P.', nickname: 'JP', goal: 'Stay Active'),
    ];
    sessions = [
      TrainingSession(
        id: 's-1',
        clientId: 'c-alex',
        at: today.add(const Duration(hours: 7)),
        title: 'Push Day',
        attended: true,
        elapsedSec: 34 * 60 + 27,
        lifts: const [
          LiftLine(exercise: 'Barbell Bench Press', sets: 4, reps: 6, weightLb: 155),
          LiftLine(exercise: 'Incline Dumbbell Press', sets: 3, reps: 8, weightLb: 50),
          LiftLine(exercise: 'Overhead Press', sets: 3, reps: 8, weightLb: 85),
        ],
      ),
      TrainingSession(
        id: 's-2',
        clientId: 'c-mia',
        at: today.add(const Duration(hours: 9)),
        title: 'Lower',
        attended: true,
      ),
      TrainingSession(
        id: 's-3',
        clientId: 'c-jon',
        at: today.add(const Duration(hours: 18)),
        title: 'Full body',
      ),
    ];
    // Backfill attended sessions this month for 19/22
    for (var i = 0; i < 19; i++) {
      sessions = [
        ...sessions,
        TrainingSession(
          id: 's-past-$i',
          clientId: i.isEven ? 'c-alex' : 'c-mia',
          at: today.subtract(Duration(days: 1 + i)),
          title: 'Session',
          attended: true,
        ),
      ];
    }
    for (var i = 0; i < 3; i++) {
      sessions = [
        ...sessions,
        TrainingSession(
          id: 's-miss-$i',
          clientId: 'c-jon',
          at: today.subtract(Duration(days: 4 + i)),
          title: 'Session',
        ),
      ];
    }
    programs = [
      ProgramPlan(
        id: 'p-push',
        name: '4-Day Strength',
        days: [
          ProgramDay(name: 'Push Day', lifts: CoachCatalog.exercises.take(3).map((e) => LiftLine(exercise: e.name)).toList()),
          const ProgramDay(name: 'Pull Day', lifts: [LiftLine(exercise: 'Barbell Row'), LiftLine(exercise: 'Lat Pulldown')]),
          const ProgramDay(name: 'Legs', lifts: [LiftLine(exercise: 'Back Squat'), LiftLine(exercise: 'Romanian Deadlift')]),
          const ProgramDay(name: 'Conditioning', lifts: [LiftLine(exercise: 'Plank', sets: 3, reps: 45)]),
        ],
      ),
    ];
    packs = const [
      SessionPack(id: 'k-alex', clientId: 'c-alex', total: 12, used: 5, price: 720),
    ];
    payments = [
      Payment(id: 'pay-1', clientId: 'c-alex', amount: 4250, status: PayStatus.collected, at: today.subtract(const Duration(days: 2))),
      Payment(id: 'pay-2', clientId: 'c-mia', amount: 750, status: PayStatus.pending, at: today),
      Payment(id: 'pay-3', clientId: 'c-jon', amount: 200, status: PayStatus.overdue, at: today.subtract(const Duration(days: 10))),
    ];
    activeSessionId = 's-1';
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}
