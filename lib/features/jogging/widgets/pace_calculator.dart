import 'package:flutter/material.dart';
import '../../../core/models/jogging.dart';

class PaceCalculator extends StatefulWidget {
  const PaceCalculator({super.key});

  @override
  State<PaceCalculator> createState() => _PaceCalculatorState();
}

class _PaceCalculatorState extends State<PaceCalculator> {
  double _age = 30;

  @override
  Widget build(BuildContext context) {
    final bpm = nikoNikoBpm(_age.round());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age slider
            Row(
              children: [
                const Text('年齡：', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_age.round()} 歲',
                    style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            Slider(
              value: _age,
              min: 15,
              max: 85,
              divisions: 70,
              activeColor: const Color(0xFF4CAF50),
              label: '${_age.round()} 歲',
              onChanged: (v) => setState(() => _age = v),
            ),

            const Divider(),
            const SizedBox(height: 8),

            // Result
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResultTile(
                  label: 'Niko-Niko 心率',
                  value: '$bpm BPM',
                  sub: '138 − 0.7 × ${_age.round()}',
                  color: Colors.red.shade400,
                ),
                _ResultTile(
                  label: '建議感覺',
                  value: '😊 微笑',
                  sub: '能輕鬆說話',
                  color: Colors.amber.shade600,
                ),
                _ResultTile(
                  label: '強度區間',
                  value: '低強度',
                  sub: '最大心率 50–60%',
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4CAF50).withAlpha(80)),
              ),
              child: Text(
                '💡 跑步時心率維持在 $bpm ± 5 BPM 左右。'
                '若沒有心率錶，以「能微笑說完整句子」為判斷標準。',
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color});
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: color),
            textAlign: TextAlign.center),
        Text(sub,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center),
      ],
    );
  }
}
