import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../../../shared/widgets/youtube_player.dart';
import '../../plan/widgets/add_to_schedule_sheet.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise});
  final Exercise exercise;

  String? _youtubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host == 'youtu.be') return uri.pathSegments.firstOrNull;
    return uri.queryParameters['v'];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final videoId =
        exercise.videoUrl != null ? _youtubeId(exercise.videoUrl!) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            exercise.primaryMuscle.label[0],
            style: TextStyle(
                color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(exercise.nameChinese,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${exercise.primaryMuscle.label}  ·  ${_equipLabel(exercise.equipment)}'
          '${exercise.sets != null ? "  ·  ${exercise.sets}組 × ${exercise.reps ?? "${exercise.holdSeconds}秒"}" : ""}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Video thumbnail ────────────────────────────────────
                if (videoId != null) ...[
                  YoutubePlayer(videoId: videoId),
                  const SizedBox(height: 14),
                ],

                // ── Instructions ───────────────────────────────────────
                if (exercise.instructions.isNotEmpty) ...[
                  const Text('動作步驟',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...exercise.instructions.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${e.key + 1}. ${e.value}'),
                        ),
                      ),
                ],

                // ── Tips ───────────────────────────────────────────────
                if (exercise.tips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('訓練提示',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...exercise.tips.map(
                    (t) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(t)),
                      ],
                    ),
                  ),
                ],

                // ── Add to weekly schedule ─────────────────────────────
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => showAddToScheduleSheet(context, exercise),
                    icon: const Icon(Icons.add_task, size: 18),
                    label: const Text('加入每週計畫'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _equipLabel(Equipment e) => switch (e) {
        Equipment.barbell    => '槓鈴',
        Equipment.dumbbell   => '啞鈴',
        Equipment.machine    => '機器',
        Equipment.cable      => '纜繩',
        Equipment.bodyweight => '自重',
        Equipment.band       => '彈力帶',
      };
}
