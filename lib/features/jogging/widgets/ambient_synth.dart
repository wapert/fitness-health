import 'dart:math';
import 'dart:typed_data';

/// Pure-Dart ambient sound synthesis.
///
/// Generates seamless-looping mono WAV buffers with no audio assets and no
/// network — the same file-based approach the metronome uses. Runs off the UI
/// thread via `compute(buildAmbientWav, index)`.
///
/// Modulated sounds (rain/ocean/wind) use LFOs whose phase is `2π · cycles ·
/// i/n`, so they complete whole cycles over the buffer and loop without a click.
/// Noise sounds loop cleanly because a one-sample jump between random values is
/// inaudible.

enum AmbientType {
  white,
  pink,
  brown,
  rain,
  ocean,
  wind,
  piano,
  forestBirds,
  flowingStream,
  nightCrickets,
}

const int _sampleRate = 44100;
const int _durationSec = 12;

/// Top-level so it can run in a background isolate via `compute`.
/// [typeIndex] is an [AmbientType] index.
Uint8List buildAmbientWav(int typeIndex) {
  final type = AmbientType.values[typeIndex];
  const n = _sampleRate * _durationSec;
  final samples = Float64List(n);
  final rng = Random(42); // fixed seed → deterministic, cacheable

  double nextWhite() => rng.nextDouble() * 2 - 1;

  switch (type) {
    case AmbientType.white:
      for (var i = 0; i < n; i++) {
        samples[i] = nextWhite() * 0.22;
      }
      break;

    case AmbientType.pink:
      // Paul Kellet's economical pink-noise filter.
      double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
      for (var i = 0; i < n; i++) {
        final w = nextWhite();
        b0 = 0.99886 * b0 + w * 0.0555179;
        b1 = 0.99332 * b1 + w * 0.0750759;
        b2 = 0.96900 * b2 + w * 0.1538520;
        b3 = 0.86650 * b3 + w * 0.3104856;
        b4 = 0.55000 * b4 + w * 0.5329522;
        b5 = -0.7616 * b5 - w * 0.0168980;
        final pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) * 0.11;
        b6 = w * 0.115926;
        samples[i] = pink * 0.5;
      }
      break;

    case AmbientType.brown:
      // Leaky integrator → deep "brown/red" noise.
      double last = 0;
      for (var i = 0; i < n; i++) {
        final w = nextWhite();
        last = (last + 0.02 * w) / 1.02;
        samples[i] = (last * 3.5).clamp(-1.0, 1.0) * 0.6;
      }
      break;

    case AmbientType.rain:
      // Broadband rain wash: low rumble + mid "patter" band + high hiss,
      // with a slow amplitude drift for life. No discrete tones (those sound
      // electronic) — real rain is dense filtered noise.
      double lpR = 0, lpM = 0, lpH = 0, drift = 0;
      for (var i = 0; i < n; i++) {
        final w = nextWhite();
        lpR += 0.04 * (w - lpR); // low rumble
        lpM += 0.20 * (w - lpM); // mid
        lpH += 0.55 * (w - lpH);
        final body = lpM - lpR; // band-pass → patter texture
        final hiss = w - lpH; // high-pass → hiss
        drift += 0.0010 * (nextWhite() - drift);
        final amp = (0.85 + 0.35 * drift).clamp(0.5, 1.2);
        samples[i] = ((lpR * 0.5 + body * 0.9 + hiss * 0.30) * amp * 0.9)
            .clamp(-1.0, 1.0);
      }
      break;

    case AmbientType.ocean:
      // Low-passed rumble shaped by asymmetric waves (fast swell, slow recede)
      // with foam hiss at each crest.
      double lp = 0, lpFoam = 0;
      const aOcean = 0.030;
      double waveEnv(double phase) {
        final x = phase - phase.floorToDouble();
        return x < 0.3 ? x / 0.3 : 1 - (x - 0.3) / 0.7; // rise 30%, fall 70%
      }
      for (var i = 0; i < n; i++) {
        final w = nextWhite();
        lp += aOcean * (w - lp);
        final t = i / n;
        final wave = 0.55 * waveEnv(t * 2) + 0.45 * waveEnv(t * 3 + 0.5);
        lpFoam += 0.5 * (w - lpFoam);
        final foam = (w - lpFoam) * max(0.0, wave - 0.55) * 1.6;
        samples[i] = (lp * 5.5 * wave + foam * 0.4).clamp(-1.0, 1.0) * 0.85;
      }
      break;

    case AmbientType.wind:
      // Layer several filtered-noise bands for soft moving air. The low band
      // supplies the body, the mid band creates the passing "whoosh", and a
      // restrained high band adds air without turning into white-noise hiss.
      // Whole-cycle LFOs keep the 12-second buffer seamless when looped.
      double low1 = 0, low2 = 0;
      double mid1 = 0, mid2 = 0;
      double airLp = 0;
      double drift1 = 0, drift2 = 0;
      for (var i = 0; i < n; i++) {
        final lowNoise = nextWhite();
        final midNoise = nextWhite();
        final airNoise = nextWhite();
        final t = i / n;

        // Slow irregular drift avoids the mechanical rise/fall of one sine.
        drift1 += 0.00035 * (nextWhite() - drift1);
        drift2 += 0.00012 * (nextWhite() - drift2);
        final periodicGust = 0.14 * sin(2 * pi * 2 * t + 0.4) +
            0.08 * sin(2 * pi * 3 * t + 2.1) +
            0.05 * sin(2 * pi * 5 * t + 4.2);
        final gust = (0.62 + periodicGust + drift1 * 2.2 + drift2 * 3.0)
            .clamp(0.28, 1.0);

        // Cascaded one-pole filters produce a broad, soft low-frequency body.
        low1 += 0.010 * (lowNoise - low1);
        low2 += 0.004 * (low1 - low2);

        // A band of moving air that becomes slightly brighter during gusts.
        final midCutoff = 0.025 + 0.035 * gust;
        mid1 += midCutoff * (midNoise - mid1);
        mid2 += 0.006 * (mid1 - mid2);
        final whoosh = mid1 - mid2;

        // Quiet high-frequency airflow, high-passed to remove harsh body.
        airLp += 0.18 * (airNoise - airLp);
        final air = airNoise - airLp;

        final body = low2 * 7.0;
        final movingAir = whoosh * 2.2;
        final softHiss = air * 0.055;
        samples[i] =
            ((body + movingAir + softHiss) * gust * 0.72).clamp(-1.0, 1.0);
      }
      break;

    case AmbientType.piano:
    case AmbientType.forestBirds:
    case AmbientType.flowingStream:
    case AmbientType.nightCrickets:
      throw UnsupportedError('${type.name} uses a bundled audio asset.');
  }

  return _encodeWav(samples);
}

Uint8List _encodeWav(Float64List samples, {int sampleRate = _sampleRate}) {
  final n = samples.length;
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
    final v = (samples[i] * 30000).round().clamp(-32768, 32767);
    buf.setInt16(44 + i * 2, v, Endian.little);
  }
  return buf.buffer.asUint8List();
}
