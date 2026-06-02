import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _SoundItem {
  const _SoundItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.videoId,
    required this.duration,
    required this.color,
  });
  final String icon;
  final String title;
  final String subtitle;
  final String videoId;
  final String duration;
  final Color color;
}

const _sounds = [
  // Nature
  _SoundItem(
    icon: '🌧️',
    title: '輕柔雨聲',
    subtitle: '溫和細雨・放鬆減壓',
    videoId: 'q76bMs-NwRk',
    duration: '3 小時',
    color: Color(0xFF1565C0),
  ),
  _SoundItem(
    icon: '🌊',
    title: '海浪聲',
    subtitle: '沙灘海浪・清新舒緩',
    videoId: 'Z0m_0o5JtAo',
    duration: '10 小時',
    color: Color(0xFF006064),
  ),
  _SoundItem(
    icon: '🌳',
    title: '森林鳥鳴',
    subtitle: '晨間森林・鳥語花香',
    videoId: 'xNN7iTA57jM',
    duration: '3 小時',
    color: Color(0xFF2E7D32),
  ),
  _SoundItem(
    icon: '🦗',
    title: '夜晚蟲鳴',
    subtitle: '夏夜蟬鳴蟋蟀・靜謐自然',
    videoId: 'yJg-Y5byMMw',
    duration: '8 小時',
    color: Color(0xFF4527A0),
  ),
  // Urban
  _SoundItem(
    icon: '☕',
    title: '咖啡廳環境音',
    subtitle: '輕聲談話・杯盤輕碰・白噪音',
    videoId: 'gaGrHFBFBQs',
    duration: '2 小時',
    color: Color(0xFF4E342E),
  ),
  _SoundItem(
    icon: '🌬️',
    title: '白噪音',
    subtitle: '純淨白噪音・遮蔽雜音・專注',
    videoId: 'nMfPqeZjc2c',
    duration: '10 小時',
    color: Color(0xFF37474F),
  ),
  // Music
  _SoundItem(
    icon: '🎵',
    title: 'Lo-Fi 節奏',
    subtitle: '放鬆嘻哈節拍・不干擾思緒',
    videoId: 'jfKfPfyJRdk',
    duration: '直播',
    color: Color(0xFF6A1B9A),
  ),
  _SoundItem(
    icon: '🥁',
    title: '180 BPM 跑步節拍',
    subtitle: '專為跑步設計・維持超慢跑步頻',
    videoId: 'oNkCnGaGcvE',
    duration: '30 分鐘',
    color: Color(0xFFE65100),
  ),
];

class SoundLibrary extends StatelessWidget {
  const SoundLibrary({super.key});

  Future<void> _open(String videoId) async {
    final app = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
    final web = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(app)) {
      await launchUrl(app);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _sounds.map((s) => _SoundCard(sound: s, onTap: () => _open(s.videoId))).toList(),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({required this.sound, required this.onTap});
  final _SoundItem sound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // ── Icon tile (gradient + emoji, no external thumbnail) ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    sound.color.withAlpha(220),
                    sound.color.withAlpha(160),
                  ],
                ),
              ),
              child: Center(
                child: Text(sound.icon,
                    style: const TextStyle(fontSize: 34)),
              ),
            ),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(sound.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sound.color.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(sound.duration,
                              style: TextStyle(
                                  fontSize: 10, color: sound.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(sound.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // ── Play arrow ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.open_in_new,
                  size: 18, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
