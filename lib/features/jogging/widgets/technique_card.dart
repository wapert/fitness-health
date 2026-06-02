import 'package:flutter/material.dart';
import '../../../core/models/jogging.dart';
import '../../../shared/widgets/youtube_player.dart';

class TechniqueCard extends StatelessWidget {
  const TechniqueCard({super.key, required this.tip});
  final JoggingTechniqueTip tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Text(tip.icon, style: const TextStyle(fontSize: 28)),
        title: Text(tip.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tip.videoId != null) ...[
                  YoutubePlayer(videoId: tip.videoId!),
                  const SizedBox(height: 12),
                ],
                Text(tip.description,
                    style: const TextStyle(height: 1.7, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
