import 'muscle_group.dart';

enum ExerciseType { strength, stretch }
enum Equipment { barbell, dumbbell, machine, cable, bodyweight, band }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.nameChinese,
    required this.type,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.videoUrl,
    this.instructions = const [],
    this.tips = const [],
    this.sets,
    this.reps,
    this.holdSeconds, // for stretches
  });

  final String id;
  final String name;
  final String nameChinese;
  final ExerciseType type;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final String? videoUrl;
  final List<String> instructions;
  final List<String> tips;
  final int? sets;
  final String? reps;        // e.g. "8-12"
  final int? holdSeconds;    // for stretches e.g. 30
}
