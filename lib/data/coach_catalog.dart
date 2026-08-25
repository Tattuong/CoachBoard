class ExerciseMove {
  final String id;
  final String name;
  final String group;
  const ExerciseMove(this.id, this.name, this.group);
}

class EquipItem {
  final String id;
  final String name;
  const EquipItem(this.id, this.name);
}

class CoachCatalog {
  CoachCatalog._();

  static const goals = ['Build Muscle', 'Lose Fat', 'Get Stronger', 'Stay Active'];

  static const exercises = <ExerciseMove>[
    ExerciseMove('bench', 'Barbell Bench Press', 'Push'),
    ExerciseMove('incline', 'Incline Dumbbell Press', 'Push'),
    ExerciseMove('ohp', 'Overhead Press', 'Push'),
    ExerciseMove('row', 'Barbell Row', 'Pull'),
    ExerciseMove('pulldown', 'Lat Pulldown', 'Pull'),
    ExerciseMove('squat', 'Back Squat', 'Legs'),
    ExerciseMove('rdl', 'Romanian Deadlift', 'Legs'),
    ExerciseMove('lunge', 'Walking Lunge', 'Legs'),
    ExerciseMove('plank', 'Plank', 'Core'),
  ];

  static const equipment = <EquipItem>[
    EquipItem('bar', 'Barbell'),
    EquipItem('db', 'Dumbbells'),
    EquipItem('bench', 'Flat bench'),
    EquipItem('rack', 'Squat rack'),
    EquipItem('cable', 'Cable stack'),
    EquipItem('mat', 'Floor mat'),
  ];

  static ExerciseMove byId(String id) =>
      exercises.firstWhere((e) => e.id == id, orElse: () => exercises.first);
}
