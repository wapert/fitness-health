import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

/// Inline YouTube player.
///
/// Shows a thumbnail with a play button; tapping loads the official YouTube
/// IFrame player **inside the app** (Android/iOS/macOS/Web). If the video's
/// owner has disabled embedding (error 101/150) the widget falls back to
/// opening the video in the YouTube app / browser.
class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({super.key, required this.videoId});
  final String videoId;

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  yt.YoutubePlayerController? _controller;
  bool _started = false;   // user tapped play → inline player mounted
  bool _failed = false;    // embedding not allowed → fall back to external
  bool _thumbnailLoaded = false;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _start() {
    final controller = yt.YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const yt.YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        enableCaption: false,
      ),
    );

    // Watch for embed-not-allowed / not-found errors and fall back.
    controller.listen((value) {
      final err = value.error;
      if (err != yt.YoutubeError.none &&
          err != yt.YoutubeError.unknown &&
          !_failed &&
          mounted) {
        setState(() => _failed = true);
      }
    });

    setState(() {
      _controller = controller;
      _started = true;
    });
  }

  Future<void> _openExternally() async {
    final appUri =
        Uri.parse('youtube://www.youtube.com/watch?v=${widget.videoId}');
    final webUri =
        Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Embedding blocked → show fallback card that launches YouTube externally.
    if (_failed) {
      return _FallbackCard(onTap: _openExternally);
    }

    // Playing inline.
    if (_started && _controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: yt.YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
        ),
      );
    }

    // Default: thumbnail with play button.
    return _Thumbnail(
      videoId: widget.videoId,
      loaded: _thumbnailLoaded,
      onThumbnailLoaded: () => setState(() => _thumbnailLoaded = true),
      onTap: _start,
    );
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.videoId,
    required this.loaded,
    required this.onThumbnailLoaded,
    required this.onTap,
  });

  final String videoId;
  final bool loaded;
  final VoidCallback onThumbnailLoaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumbUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => onThumbnailLoaded());
                    return child;
                  }
                  return Container(
                    color: scheme.surfaceContainerHighest,
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
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Icons.video_library,
                      size: 48, color: scheme.onSurfaceVariant),
                ),
              ),
              if (loaded) Container(color: Colors.black.withAlpha(60)),
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
                      Text('點擊播放',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
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

// ── Fallback (embedding disabled) ─────────────────────────────────────────────

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.open_in_new, size: 32, color: Colors.red),
              const SizedBox(height: 8),
              Text('此影片不支援內嵌播放',
                  style: TextStyle(color: scheme.onSurface)),
              const SizedBox(height: 2),
              Text('點擊在 YouTube 開啟',
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
