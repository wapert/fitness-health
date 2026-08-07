import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/fasting.dart';
import '../services/fasting_service.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen>
    with WidgetsBindingObserver {
  final _service = FastingService();
  FastingProtocol _protocol = FastingProtocol.sixteen8;
  FastingSession? _session;
  Timer? _ticker;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  Future<void> _restore() async {
    final session = await _service.load();
    if (!mounted) return;
    setState(() {
      _session = session;
      if (session != null) _protocol = session.protocol;
      _loading = false;
    });
    if (session?.isActive ?? false) _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _start() async {
    final now = DateTime.now();
    final session = FastingSession(
      protocol: _protocol,
      startTime: now,
      updatedAt: now,
    );
    setState(() {
      _session = session;
    });
    _startTicker();
    await _service.save(session);
  }

  Future<void> _stop() async {
    final current = _session;
    if (current == null) return;
    final now = DateTime.now();
    final completed = FastingSession(
      protocol: current.protocol,
      startTime: current.startTime,
      endTime: now,
      updatedAt: now,
    );
    _ticker?.cancel();
    setState(() {
      _session = completed;
    });
    await _service.save(completed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = _session;
    final progress = session != null ? session.progress.clamp(0.0, 1.0) : 0.0;
    final elapsed = session?.elapsed ?? Duration.zero;
    final active = session != null && session.isActive;

    return Scaffold(
      appBar: AppBar(title: const Text('斷食計時器 Fasting Timer')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // ── Protocol selector (hidden while active) ───────────────
                  if (!active) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('選擇斷食協議',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: scheme.onSurface)),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: FastingProtocol.values
                            .map((p) => RadioListTile<FastingProtocol>(
                                  dense: true,
                                  title: Text(p.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(p.description,
                                      style: const TextStyle(fontSize: 12)),
                                  value: p,
                                  groupValue: _protocol,
                                  onChanged: (v) =>
                                      setState(() => _protocol = v!),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Timer ring (not shown for 5:2) ───────────────────────
                  if (_protocol != FastingProtocol.fiveTwo) ...[
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 14,
                              backgroundColor: scheme.surfaceVariant,
                              color: progress >= 1.0
                                  ? Colors.green
                                  : scheme.primary,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _fmt(elapsed),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session == null
                                    ? '準備開始'
                                    : progress >= 1.0
                                        ? '🎉 目標達成！'
                                        : '還剩 ${_fmt(session.target - elapsed)}',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              if (active) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _protocol.label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // 5:2 — simple day status card instead of a timer ring
                    Card(
                      color: scheme.primaryContainer.withAlpha(80),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text('5:2 週間斷食',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: scheme.primary)),
                            const SizedBox(height: 8),
                            const Text(
                              '每週選擇 2 天攝取極低熱量（約 500–600 kcal）\n其餘 5 天正常飲食',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, height: 1.6),
                            ),
                            if (active) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 16, color: scheme.primary),
                                    const SizedBox(width: 6),
                                    Text('今日斷食中  ${_fmt(elapsed)}',
                                        style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Start / Stop button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: active
                        ? OutlinedButton.icon(
                            onPressed: _stop,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('結束斷食'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.error,
                              side: BorderSide(color: scheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _start,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(_protocol == FastingProtocol.fiveTwo
                                ? '開始今日斷食日'
                                : '開始斷食  ${_protocol.label}'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                  ),

                  // ── Session result card ───────────────────────────────────
                  if (session != null && !session.isActive) ...[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('本次斷食紀錄',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 12),
                            _Row('協議', session.protocol.label),
                            _Row('斷食時長', _fmt(session.elapsed)),
                            if (session.protocol != FastingProtocol.fiveTwo)
                              _Row('目標', '${session.protocol.fastHours} 小時'),
                            const Divider(height: 20),
                            Text(
                              session.protocol == FastingProtocol.fiveTwo
                                  ? '✓ 今日斷食日完成！'
                                  : session.progress >= 1.0
                                      ? '🎉 達成目標！'
                                      : '未達目標（${(session.progress * 100).toStringAsFixed(0)}%）',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: session.progress >= 1.0
                                    ? Colors.green
                                    : scheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
