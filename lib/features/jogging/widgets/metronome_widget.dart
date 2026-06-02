import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

// ── Sound types ───────────────────────────────────────────────────────────────

enum _SoundType { simple, kickDrum, deepBeat, woodBlock, deepBass }

class _Tone {
  const _Tone({
    required this.emoji,
    required this.label,
    required this.type,
  });
  final String emoji;
  final String label;
  final _SoundType type;
}

const _tones = [
  _Tone(emoji: '🔔', label: '清脆',  type: _SoundType.simple),
  _Tone(emoji: '🎵', label: '中音',  type: _SoundType.deepBass),
  _Tone(emoji: '🥁', label: '大鼓',  type: _SoundType.kickDrum),
  _Tone(emoji: '🪘', label: '低拍',  type: _SoundType.deepBeat),
  _Tone(emoji: '🎸', label: '木魚',  type: _SoundType.woodBlock),
];

// ── File source helper ────────────────────────────────────────────────────────

Future<AudioSource> _wavToFileSource(Uint8List bytes, String name) async {
  final dir = await getApplicationCacheDirectory();
  final file = File('${dir.path}/$name.wav');
  await file.writeAsBytes(bytes, flush: true);
  return AudioSource.uri(Uri.file(file.path));
}

// ── Widget ────────────────────────────────────────────────────────────────────

class MetronomeWidget extends StatefulWidget {
  const MetronomeWidget({super.key});

  @override
  State<MetronomeWidget> createState() => _MetronomeWidgetState();
}

class _MetronomeWidgetState extends State<MetronomeWidget>
    with SingleTickerProviderStateMixin {
  double _bpm = 180;
  int _toneIdx = 2; // default to 大鼓
  bool _running = false;
  bool _beat = false;
  bool _audioReady = false;
  Timer? _timer;

  late final AudioPlayer _player;
  late final AnimationController _pulseCtrl;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _player = AudioPlayer();
    _loadTone(_toneIdx);
  }

  Future<void> _loadTone(int idx) async {
    setState(() => _audioReady = false);
    try {
      final bytes = _generateTone(_tones[idx].type);
      final source = await _wavToFileSource(bytes, 'tone_$idx');
      await _player.setAudioSource(source);
      if (mounted) setState(() => _audioReady = true);
    } catch (e) {
      debugPrint('Metronome audio error: $e');
    }
  }

  // ── Sound generators ───────────────────────────────────────────────────────

  double get _n => _rng.nextDouble() * 2 - 1; // white noise sample

  Uint8List _generateTone(_SoundType type) {
    switch (type) {
      case _SoundType.simple:
        return _buildWav(durationMs: 60, generator: (t, _) {
          return sin(2 * pi * 880 * t) * exp(-t * 55);
        });

      case _SoundType.kickDrum:
        // ── Realistic kick drum ─────────────────────────────────────
        // Layer 1: pitch sweep 280 Hz → 40 Hz (fast, in first 70 ms)
        // Layer 2: white noise burst at attack (THE key ingredient)
        // Layer 3: sub bass 50 Hz, slow decay
        // Layer 4: beater click 1200 Hz, ultra-fast decay
        return _buildWav(durationMs: 340, generator: (t, _) {
          // Fast pitch sweep — most of the drop happens in first 70ms
          final sweepT    = (t / 0.07).clamp(0.0, 1.0);
          final bodyFreq  = 280.0 * pow(40.0 / 280.0, sweepT);
          final bodyEnv   = exp(-t * 11);
          final body      = sin(2 * pi * bodyFreq * t) * bodyEnv * 0.9;

          // White noise burst — gives the physical "thud" and punch
          final noiseEnv  = exp(-t * 180);
          final noise     = _n * noiseEnv * 0.7;

          // Sub bass — perceived depth on speakers/headphones
          final subEnv    = exp(-t * 7);
          final sub       = sin(2 * pi * 50 * t) * subEnv * 0.5;

          // Beater click — sharp transient attack
          final clickEnv  = exp(-t * 280);
          final click     = sin(2 * pi * 1200 * t) * clickEnv * 0.35;

          return (body + noise + sub + click).clamp(-1.0, 1.0);
        });

      case _SoundType.deepBeat:
        // ── Floor tom / deep beat ───────────────────────────────────
        // Slower pitch sweep + noise + longer body
        return _buildWav(durationMs: 300, generator: (t, _) {
          final sweepT   = (t / 0.12).clamp(0.0, 1.0);
          final bodyFreq = 160.0 * pow(65.0 / 160.0, sweepT);
          final bodyEnv  = exp(-t * 9);
          final body     = sin(2 * pi * bodyFreq * t) * bodyEnv;

          // Moderate noise — softer than kick
          final noiseEnv = exp(-t * 120);
          final noise    = _n * noiseEnv * 0.4;

          // Warm harmonic
          final harmEnv  = exp(-t * 14);
          final harm     = sin(2 * pi * bodyFreq * 2 * t) * harmEnv * 0.25;

          // Sub
          final subEnv   = exp(-t * 10);
          final sub      = sin(2 * pi * 60 * t) * subEnv * 0.3;

          return (body + noise + harm + sub).clamp(-1.0, 1.0);
        });

      case _SoundType.woodBlock:
        // ── Wood block — short, dry, mid-high ──────────────────────
        return _buildWav(durationMs: 85, generator: (t, _) {
          final env  = exp(-t * 70);
          final env2 = exp(-t * 100);
          final a    = sin(2 * pi * 620 * t) * env;
          final b    = sin(2 * pi * 950 * t) * env2 * 0.4;
          // Tiny noise snap
          final snap = _n * exp(-t * 500) * 0.2;
          return (a + b + snap).clamp(-1.0, 1.0);
        });

      case _SoundType.deepBass:
        // ── Deep warm bell tone ────────────────────────────────────
        return _buildWav(durationMs: 120, generator: (t, _) {
          final env = exp(-t * 28);
          final a   = sin(2 * pi * 440 * t) * env;
          final b   = sin(2 * pi * 880 * t) * env * 0.3;
          final c   = sin(2 * pi * 220 * t) * env * 0.2;
          return (a + b + c).clamp(-1.0, 1.0);
        });
    }
  }

  // ── Core WAV builder ───────────────────────────────────────────────────────

  Uint8List _buildWav({
    required int durationMs,
    required double Function(double t, double progress) generator,
    int sampleRate = 44100,
  }) {
    final n   = (sampleRate * durationMs / 1000).round();
    final buf = ByteData(44 + n * 2);

    void str(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    buf.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little); // PCM
    buf.setUint16(22, 1, Endian.little); // mono
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little);
    buf.setUint16(34, 16, Endian.little);
    str(36, 'data');
    buf.setUint32(40, n * 2, Endian.little);

    for (var i = 0; i < n; i++) {
      final t        = i / sampleRate;
      final progress = i / n;
      final sample   = generator(t, progress);
      final v        = (sample * 30000).round().clamp(-32768, 32767);
      buf.setInt16(44 + i * 2, v, Endian.little);
    }
    return buf.buffer.asUint8List();
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  void _start() {
    setState(() => _running = true);
    _tick();
    _timer = Timer.periodic(
      Duration(milliseconds: (60000 / _bpm).round()),
      (_) => _tick(),
    );
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  Future<void> _tick() async {
    if (!_audioReady) return;
    await _player.seek(Duration.zero);
    await _player.play();
    if (mounted) {
      setState(() => _beat = true);
      _pulseCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 90),
          () { if (mounted) setState(() => _beat = false); });
    }
  }

  void _onBpmChanged(double v) {
    setState(() => _bpm = v);
    if (_running) { _stop(); _start(); }
  }

  Future<void> _onToneChanged(int idx) async {
    final wasRunning = _running;
    if (wasRunning) _stop();
    setState(() => _toneIdx = idx);
    await _loadTone(idx);
    if (wasRunning) _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bpmInt = _bpm.round();
    final tone   = _tones[_toneIdx];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pulse circle
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + _pulseCtrl.value * 0.22,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _running
                        ? (_beat
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF4CAF50).withAlpha(60))
                        : scheme.surfaceVariant,
                    boxShadow: _beat
                        ? [BoxShadow(
                            color: const Color(0xFF4CAF50).withAlpha(140),
                            blurRadius: 24, spreadRadius: 6)]
                        : [],
                  ),
                  child: Center(
                    child: _audioReady
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tone.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              Text('$bpmInt BPM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _running
                                        ? Colors.white
                                        : scheme.onSurfaceVariant,
                                  )),
                            ],
                          )
                        : const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tone selector
            const Text('音色', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tones.length, (i) {
                final t      = _tones[i];
                final active = _toneIdx == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _onToneChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF4CAF50)
                            : scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: active
                            ? null
                            : Border.all(
                                color: scheme.outline.withAlpha(60)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(t.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : scheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // BPM slider  150–200
            Row(
              children: [
                const Text('150',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Expanded(
                  child: Slider(
                    value: _bpm,
                    min: 150, max: 200, divisions: 50,
                    activeColor: const Color(0xFF4CAF50),
                    label: '$bpmInt BPM',
                    onChanged: _onBpmChanged,
                  ),
                ),
                const Text('200',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            // Preset chips  150–200
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [150, 160, 170, 180, 190, 200].map((bpm) {
                final active = bpmInt == bpm;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => _onBpmChanged(bpm.toDouble()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF4CAF50)
                            : scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('$bpm',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: active
                                ? Colors.white
                                : scheme.onSurfaceVariant,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Text(
              bpmInt == 180 ? '✓ 標準超慢跑步頻' : '超慢跑建議 180 BPM',
              style: TextStyle(
                fontSize: 12,
                color: bpmInt == 180
                    ? const Color(0xFF4CAF50)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 14),

            // Start / Stop
            SizedBox(
              width: double.infinity,
              child: _running
                  ? OutlinedButton.icon(
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('停止節拍'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: _audioReady ? _start : null,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(_audioReady
                          ? '開始節拍  $bpmInt BPM'
                          : '音色載入中…'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
