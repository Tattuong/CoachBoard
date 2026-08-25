enum PayStatus { collected, pending, overdue }

class MeasureLog {
  final DateTime at;
  final double weightLb;
  const MeasureLog({required this.at, required this.weightLb});

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'weightLb': weightLb};

  factory MeasureLog.fromJson(Map<String, dynamic> raw) => MeasureLog(
        at: DateTime.tryParse(raw['at']?.toString() ?? '') ?? DateTime.now(),
        weightLb: (raw['weightLb'] as num?)?.toDouble() ?? 0,
      );
}

class Athlete {
  final String id;
  final String name;
  final String nickname;
  final String goal;
  final String notes;
  final List<MeasureLog> measures;

  const Athlete({
    required this.id,
    required this.name,
    this.nickname = '',
    this.goal = 'Build Muscle',
    this.notes = '',
    this.measures = const [],
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Athlete copyWith({
    String? name,
    String? nickname,
    String? goal,
    String? notes,
    List<MeasureLog>? measures,
  }) =>
      Athlete(
        id: id,
        name: name ?? this.name,
        nickname: nickname ?? this.nickname,
        goal: goal ?? this.goal,
        notes: notes ?? this.notes,
        measures: measures ?? this.measures,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'goal': goal,
        'notes': notes,
        'measures': [for (final m in measures) m.toJson()],
      };

  factory Athlete.fromJson(Map<String, dynamic> raw) => Athlete(
        id: raw['id']?.toString() ?? '',
        name: raw['name']?.toString() ?? '',
        nickname: raw['nickname']?.toString() ?? '',
        goal: raw['goal']?.toString() ?? 'Build Muscle',
        notes: raw['notes']?.toString() ?? '',
        measures: [
          for (final m in (raw['measures'] as List? ?? const []))
            if (m is Map) MeasureLog.fromJson(Map<String, dynamic>.from(m)),
        ],
      );
}

class LiftLine {
  final String exercise;
  final int sets;
  final int reps;
  final double weightLb;

  const LiftLine({required this.exercise, this.sets = 3, this.reps = 8, this.weightLb = 0});

  LiftLine copyWith({String? exercise, int? sets, int? reps, double? weightLb}) => LiftLine(
        exercise: exercise ?? this.exercise,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weightLb: weightLb ?? this.weightLb,
      );

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        'sets': sets,
        'reps': reps,
        'weightLb': weightLb,
      };

  factory LiftLine.fromJson(Map<String, dynamic> raw) => LiftLine(
        exercise: raw['exercise']?.toString() ?? '',
        sets: (raw['sets'] as num?)?.toInt() ?? 3,
        reps: (raw['reps'] as num?)?.toInt() ?? 8,
        weightLb: (raw['weightLb'] as num?)?.toDouble() ?? 0,
      );
}

class ProgramDay {
  final String name;
  final List<LiftLine> lifts;
  const ProgramDay({required this.name, this.lifts = const []});

  Map<String, dynamic> toJson() => {
        'name': name,
        'lifts': [for (final l in lifts) l.toJson()],
      };

  factory ProgramDay.fromJson(Map<String, dynamic> raw) => ProgramDay(
        name: raw['name']?.toString() ?? 'Day',
        lifts: [
          for (final l in (raw['lifts'] as List? ?? const []))
            if (l is Map) LiftLine.fromJson(Map<String, dynamic>.from(l)),
        ],
      );
}

class ProgramPlan {
  final String id;
  final String name;
  final List<ProgramDay> days;
  const ProgramPlan({required this.id, required this.name, this.days = const []});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'days': [for (final d in days) d.toJson()],
      };

  factory ProgramPlan.fromJson(Map<String, dynamic> raw) => ProgramPlan(
        id: raw['id']?.toString() ?? '',
        name: raw['name']?.toString() ?? '',
        days: [
          for (final d in (raw['days'] as List? ?? const []))
            if (d is Map) ProgramDay.fromJson(Map<String, dynamic>.from(d)),
        ],
      );
}

class TrainingSession {
  final String id;
  final String clientId;
  final DateTime at;
  final String title;
  final bool attended;
  final int elapsedSec;
  final bool running;
  final List<LiftLine> lifts;

  const TrainingSession({
    required this.id,
    required this.clientId,
    required this.at,
    this.title = 'Session',
    this.attended = false,
    this.elapsedSec = 0,
    this.running = false,
    this.lifts = const [],
  });

  TrainingSession copyWith({
    DateTime? at,
    String? title,
    bool? attended,
    int? elapsedSec,
    bool? running,
    List<LiftLine>? lifts,
  }) =>
      TrainingSession(
        id: id,
        clientId: clientId,
        at: at ?? this.at,
        title: title ?? this.title,
        attended: attended ?? this.attended,
        elapsedSec: elapsedSec ?? this.elapsedSec,
        running: running ?? this.running,
        lifts: lifts ?? this.lifts,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'at': at.toIso8601String(),
        'title': title,
        'attended': attended,
        'elapsedSec': elapsedSec,
        'running': running,
        'lifts': [for (final l in lifts) l.toJson()],
      };

  factory TrainingSession.fromJson(Map<String, dynamic> raw) => TrainingSession(
        id: raw['id']?.toString() ?? '',
        clientId: raw['clientId']?.toString() ?? '',
        at: DateTime.tryParse(raw['at']?.toString() ?? '') ?? DateTime.now(),
        title: raw['title']?.toString() ?? 'Session',
        attended: raw['attended'] == true,
        elapsedSec: (raw['elapsedSec'] as num?)?.toInt() ?? 0,
        running: raw['running'] == true,
        lifts: [
          for (final l in (raw['lifts'] as List? ?? const []))
            if (l is Map) LiftLine.fromJson(Map<String, dynamic>.from(l)),
        ],
      );
}

class SessionPack {
  final String id;
  final String clientId;
  final int total;
  final int used;
  final double price;

  const SessionPack({
    required this.id,
    required this.clientId,
    this.total = 8,
    this.used = 0,
    this.price = 0,
  });

  int get left => total - used < 0 ? 0 : total - used;

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'total': total,
        'used': used,
        'price': price,
      };

  factory SessionPack.fromJson(Map<String, dynamic> raw) => SessionPack(
        id: raw['id']?.toString() ?? '',
        clientId: raw['clientId']?.toString() ?? '',
        total: (raw['total'] as num?)?.toInt() ?? 8,
        used: (raw['used'] as num?)?.toInt() ?? 0,
        price: (raw['price'] as num?)?.toDouble() ?? 0,
      );
}

class Payment {
  final String id;
  final String clientId;
  final double amount;
  final PayStatus status;
  final DateTime at;

  const Payment({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.status,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'amount': amount,
        'status': status.name,
        'at': at.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> raw) => Payment(
        id: raw['id']?.toString() ?? '',
        clientId: raw['clientId']?.toString() ?? '',
        amount: (raw['amount'] as num?)?.toDouble() ?? 0,
        status: PayStatus.values.firstWhere((s) => s.name == raw['status'], orElse: () => PayStatus.pending),
        at: DateTime.tryParse(raw['at']?.toString() ?? '') ?? DateTime.now(),
      );
}
