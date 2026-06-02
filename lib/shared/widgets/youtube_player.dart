import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a YouTube video thumbnail with a play button.
/// Tapping opens the YouTube app (mobile) or browser (desktop/web).
/// This is the standard approach used by Nike Training, Peloton, etc. —
/// YouTube actively blocks WebView playback, so in-app embedding is unreliable.
class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({super.key, required this.videoId});
  final String videoId;

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  bool _thumbnailLoaded = false;

  Future<void> _open() async {
    // Try YouTube app deep-link first (works on iOS & Android)
    final appUri = Uri.parse('youtube://www.youtube.com/watch?v=${widget.videoId}');
    final webUri = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumbUrl =
        'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg';

    return GestureDetector(
      onTap: _open,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Thumbnail ────────────────────────────────────────────
              Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => setState(() => _thumbnailLoaded = true));
                    return child;
                  }
                  return Container(
                    color: scheme.surfaceVariant,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                        color: scheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceVariant,
                  child: Icon(Icons.video_library,
                      size: 48, color: scheme.onSurfaceVariant),
                ),
              ),

              // ── Dark overlay ─────────────────────────────────────────
              if (_thumbnailLoaded)
                Container(color: Colors.black.withAlpha(60)),

              // ── Play button ──────────────────────────────────────────
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(230),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 38),
                ),
              ),

              // ── "Tap to watch" label ──────────────────────────────────
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('點擊在 YouTube 觀看',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
