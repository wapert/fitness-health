import '../../../core/models/exercise.dart';
import '../../training/data/exercises_data.dart';
import '../../stretching/data/stretches_data.dart';

/// All exercises (strength + stretch) keyed by id, for resolving scheduled
/// exercise ids back to full [Exercise] objects.
final Map<String, Exercise> allExercisesById = {
  for (final e in [...strengthExercises, ...stretchingExercises]) e.id: e,
};

Exercise? exerciseById(String id) => allExercisesById[id];
