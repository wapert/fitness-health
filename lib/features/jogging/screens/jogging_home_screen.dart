import 'package:flutter/material.dart';
import '../data/jogging_data.dart';
import '../widgets/technique_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/pace_calculator.dart';
import '../widgets/benefits_card.dart';
import '../widgets/metronome_widget.dart';
import '../widgets/sound_library.dart';

class JoggingHomeScreen extends StatelessWidget {
  const JoggingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('超慢跑 Super Slow Jogging',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  ),
                ),
                child: const Center(
                  child: Text('🏃', style: TextStyle(fontSize: 72)),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Intro Card ───────────────────────────────────────────
                _IntroCard(),
                const SizedBox(height: 16),

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

                // ── Sound Library ─────────────────────────────────────────
                _SectionHeader(icon: '🎧', title: '伴跑音效'),
                const SizedBox(height: 4),
                const Text(
                  '選擇喜歡的背景音效，點擊在 YouTube 播放',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const SoundLibrary(),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1B5E20).withAlpha(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('什麼是超慢跑？',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              '超慢跑由日本九州大學田中宏暁教授研發，核心概念是：'
              '用前腳掌著地、小步幅高步頻、極慢速度（甚至比走路慢）持續跑步。\n\n'
              '速度要慢到「能夠微笑說話」——這就是「Niko-Niko（ニコニコ）配速」。'
              '在這個強度下，身體大量燃燒脂肪，對關節幾乎沒有衝擊，任何人都能持續很長時間。',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag('🐢 速度比走路慢也OK'),
                _Tag('🦵 保護膝關節'),
                _Tag('🔥 燃脂效率高'),
                _Tag('👴 老少皆宜'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(120)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
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
