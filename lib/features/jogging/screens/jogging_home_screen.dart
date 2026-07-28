import 'package:flutter/material.dart';
import '../data/jogging_data.dart';
import '../widgets/technique_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/pace_calculator.dart';
import '../widgets/benefits_card.dart';
import '../widgets/metronome_widget.dart';
import '../widgets/ambient_player.dart';

class JoggingHomeScreen extends StatelessWidget {
  const JoggingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('超慢跑 Super Slow Jogging'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Niko-Niko Pace Calculator ────────────────────────────
          _SectionHeader(icon: '❤️', title: '個人配速計算器'),
          const SizedBox(height: 8),
          const PaceCalculator(),
          const SizedBox(height: 20),

          // ── Metronome ─────────────────────────────────────────────
          _SectionHeader(icon: '🥁', title: '步頻節拍器'),
          const SizedBox(height: 4),
          const Text(
            '跑步時播放節拍音效，幫助維持 180 BPM 的標準超慢跑步頻',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const MetronomeWidget(),
          const SizedBox(height: 20),

          // ── Ambient Sound Player (in-app) ─────────────────────────
          _SectionHeader(icon: '🎧', title: '伴跑音效'),
          const SizedBox(height: 4),
          const Text(
            '點擊即可在 App 內播放循環背景音效，適合搭配超慢跑或放鬆',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const AmbientPlayer(),
          const SizedBox(height: 20),

          // ── Technique ────────────────────────────────────────────
          _SectionHeader(icon: '🦶', title: '技術要點'),
          const SizedBox(height: 8),
          ...techniqueTips.map((tip) => TechniqueCard(tip: tip)),
          const SizedBox(height: 20),

          // ── Training Plans ────────────────────────────────────────
          _SectionHeader(icon: '📅', title: '訓練計畫'),
          const SizedBox(height: 8),
          PlanCard(plan: beginnerPlan),
          const SizedBox(height: 8),
          PlanCard(plan: intermediatePlan),
          const SizedBox(height: 20),

          // ── Benefits ──────────────────────────────────────────────
          _SectionHeader(icon: '✨', title: '超慢跑的好處'),
          const SizedBox(height: 8),
          const BenefitsCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
