import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'ambient_synth.dart';

class _Ambient {
  const _Ambient({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final AmbientType type;
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
}

const _ambients = [
  _Ambient(
    type: AmbientType.rain,
    icon: '🌧️',
    title: '雨聲',
    subtitle: '細雨綿綿・放鬆減壓',
    color: Color(0xFF1565C0),
  ),
  _Ambient(
    type: AmbientType.ocean,
    icon: '🌊',
    title: '海浪聲',
    subtitle: '海浪起伏・清新舒緩',
    color: Color(0xFF006064),
  ),
  _Ambient(
    type: AmbientType.wind,
    icon: '🌬️',
    title: '風聲',
    subtitle: '徐徐微風・自然開闊',
    color: Color(0xFF00695C),
  ),
  _Ambient(
    type: AmbientType.white,
    icon: '⚪',
    title: '白噪音',
    subtitle: '純淨白噪音・遮蔽雜音',
    color: Color(0xFF37474F),
  ),
  _Ambient(
    type: AmbientType.pink,
    icon: '🌸',
    title: '粉紅噪音',
    subtitle: '柔和平衡・幫助專注',
    color: Color(0xFFAD1457),
  ),
  _Ambient(
    type: AmbientType.brown,
    icon: '🟤',
    title: '棕色噪音',
    subtitle: '低沉厚實・深度放鬆',
    color: Color(0xFF4E342E),
  ),
];

class AmbientPlayer extends StatefulWidget {
  const AmbientPlayer({super.key});

  @override
  State<AmbientPlayer> createState() => _AmbientPlayerState();
}

class _AmbientPlayerState extends State<AmbientPlayer> {
  final _player = AudioPlayer();
  int? _activeIdx;      // currently selected sound
  int? _loadingIdx;     // sound being synthesized/loaded
  bool _playing = false;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _player.setLoopMode(LoopMode.one);
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// Synthesize (once) → cache → return a looping file source.
  Future<AudioSource> _sourceFor(_Ambient a) async {
    final dir = await getApplicationCacheDirectory();
    // Version suffix busts the cache when the synthesis changes.
    final file = File('${dir.path}/ambient_${a.type.name}_v3.wav');
    if (!await file.exists()) {
      // Generate off the UI thread — ~0.5M samples of DSP.
      final bytes = await compute(buildAmbientWav, a.type.index);
      await file.writeAsBytes(bytes, flush: true);
    }
    return AudioSource.uri(Uri.file(file.path));
  }

  Future<void> _select(int idx) async {
    // Tapping the active sound toggles play/pause.
    if (_activeIdx == idx) {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.play();
        setState(() => _playing = true);
      }
      return;
    }

    setState(() => _loadingIdx = idx);
    try {
      final source = await _sourceFor(_ambients[idx]);
      await _player.setAudioSource(source);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      if (mounted) {
        setState(() {
          _activeIdx = idx;
          _playing = true;
          _loadingIdx = null;
        });
      }
    } catch (e) {
      debugPrint('Ambient audio error: $e');
      if (mounted) setState(() => _loadingIdx = null);
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() {
      _playing = false;
      _activeIdx = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // ── Sound cards ────────────────────────────────────────────────
        ..._ambients.asMap().entries.map((e) {
          final idx = e.key;
          final a = e.value;
          final active = _activeIdx == idx;
          final loading = _loadingIdx == idx;
          return _AmbientCard(
            ambient: a,
            active: active,
            playing: active && _playing,
            loading: loading,
            onTap: () => _select(idx),
          );
        }),

        // ── Volume + stop (only while something is active) ─────────────
        if (_activeIdx != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.volume_down, size: 18, color: Colors.grey),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0, max: 1,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _player.setVolume(v);
                  },
                ),
              ),
              const Icon(Icons.volume_up, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                tooltip: '停止',
                style: IconButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AmbientCard extends StatelessWidget {
  const _AmbientCard({
    required this.ambient,
    required this.active,
    required this.playing,
    required this.loading,
    required this.onTap,
  });
  final _Ambient ambient;
  final bool active;
  final bool playing;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: active
            ? BorderSide(color: ambient.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // ── Icon tile ───────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ambient.color.withAlpha(220),
                    ambient.color.withAlpha(150),
                  ],
                ),
              ),
              child: Center(
                child: Text(ambient.icon, style: const TextStyle(fontSize: 30)),
              ),
            ),

            // ── Info ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ambient.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(ambient.subtitle,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // ── Play / pause / loading indicator ───────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      size: 34,
                      color: active ? ambient.color : Colors.grey.shade400,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
