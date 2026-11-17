import 'package:hive/hive.dart';
import 'energy_level.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
/// Hive'a kalıcı olarak yazılan görev modeli.
///
/// Kutu anahtarı [id] alanıdır. [poolItemId] görev bir aktivite
/// havuzundan geliyorsa havuzdaki öğeye işaret eder; böylece aynı
/// öğe iki kez önerilmez.
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  EnergyLevel energyLevel;

  @HiveField(3)
  int durationMin;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  String? poolItemId;

  Task({
    required this.id,
    required this.title,
    required this.energyLevel,
    required this.durationMin,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    List<String>? tags,
    this.poolItemId,
  }) : createdAt = createdAt ?? DateTime.now(),
       tags = tags ?? [];

  Task copyWith({
    String? title,
    EnergyLevel? energyLevel,
    int? durationMin,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    String? poolItemId,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      energyLevel: energyLevel ?? this.energyLevel,
      durationMin: durationMin ?? this.durationMin,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      poolItemId: poolItemId ?? this.poolItemId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'energyLevel': energyLevel.index,
    'durationMin': durationMin,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'tags': tags,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['text'] as String,
    energyLevel:
        EnergyLevel.values[json['energy'] == 'low'
            ? 0
            : json['energy'] == 'high'
            ? 2
            : 1],
    durationMin: json['duration_min'] as int? ?? 5,
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
  );
}
