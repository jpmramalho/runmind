class WorkoutTemplateModel {
  final String id;
  final String level;
  final String goal;
  final int age;
  final String gender;
  final int totalSessions;
  final double estimatedWeeklyKm;
  final String focus;

  WorkoutTemplateModel({
    required this.id,
    required this.level,
    required this.goal,
    required this.age,
    required this.gender,
    required this.totalSessions,
    required this.estimatedWeeklyKm,
    required this.focus,
  });

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateModel(
      id: json['id'] ?? '',
      level: json['level'] ?? 'Iniciante',
      goal: json['goal'] ?? '5km',
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'Geral',
      totalSessions: json['weekly_summary']?['total_sessions'] ?? 3,
      estimatedWeeklyKm: (json['weekly_summary']?['estimated_weekly_km'] ?? 0.0)
          .toDouble(),
      focus: json['weekly_summary']?['focus'] ?? 'Base aeróbica',
    );
  }
}

class WorkoutItemModel {
  final String day;
  final int dayOfWeek;
  final String type;
  final String title;
  final String description;
  final int durationMin;
  final double distanceKm;
  final String intensity;
  final int rpe;
  final String notes;

  WorkoutItemModel({
    required this.day,
    required this.dayOfWeek,
    required this.type,
    required this.title,
    required this.description,
    required this.durationMin,
    required this.distanceKm,
    required this.intensity,
    required this.rpe,
    required this.notes,
  });

  factory WorkoutItemModel.fromJson(Map<String, dynamic> json) {
    return WorkoutItemModel(
      day: json['day'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 1,
      type: json['type'] ?? 'Corrida',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationMin: json['duration_min'] ?? 0,
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      intensity: json['intensity'] ?? 'Baixa',
      rpe: json['rpe'] ?? 1,
      notes: json['notes'] ?? '',
    );
  }
}
