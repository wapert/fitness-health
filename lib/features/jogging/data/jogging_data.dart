import '../../../core/models/jogging.dart';

// ── Technique Tips ─────────────────────────────────────────────────────────────

const List<JoggingTechniqueTip> techniqueTips = [
  JoggingTechniqueTip(
    icon: '🦶',
    title: '前腳掌著地',
    description:
        '超慢跑的核心技巧：以前腳掌（腳趾球）先著地，而非腳跟。'
        '這樣能自然吸收衝擊力，減少膝關節負擔。'
        '想像踮腳尖輕輕原地小跑，每步落地聲音要非常輕。',
    videoId: 'KTRzjDDCNTM',
  ),
  JoggingTechniqueTip(
    icon: '👟',
    title: '小步幅・高步頻',
    description:
        '步幅要小（腳幾乎落在身體正下方），步頻維持每分鐘 180 步左右。'
        '這與一般慢跑「大步跨出」完全相反。'
        '步幅越小，對關節的衝擊越低，可以跑很久也不累。',
  ),
  JoggingTechniqueTip(
    icon: '😊',
    title: 'Niko-Niko 配速（微笑配速）',
    description:
        '速度要慢到「能夠微笑、能夠說話」的程度。'
        '日文「ニコニコ」(niko-niko) 意思是微笑。'
        '心率控制在「138 − 0.7 × 年齡」BPM 左右，這是最佳燃脂區間。'
        '很多人的超慢跑速度甚至比快走還慢，這是正常的！',
  ),
  JoggingTechniqueTip(
    icon: '🧍',
    title: '輕鬆直立姿勢',
    description:
        '身體自然直立，輕微前傾（約 5°）。'
        '肩膀放鬆下沉，手臂自然擺動，不要刻意抬高膝蓋。'
        '頭部保持中立，視線看向前方 10–15 公尺處。',
  ),
  JoggingTechniqueTip(
    icon: '💨',
    title: '腹式呼吸',
    description:
        '超慢跑速度夠慢，可以完全用鼻子呼吸。'
        '吸氣時腹部鼓起（腹式呼吸），呼氣時收腹。'
        '若必須用嘴巴呼吸，代表速度還太快，請再放慢。',
  ),
  JoggingTechniqueTip(
    icon: '⏱️',
    title: '時間優先・不管距離',
    description:
        '超慢跑以「時間」計算，不以距離或速度為目標。'
        '初學者從每次 10–20 分鐘開始，逐週增加。'
        '每週累積 150 分鐘是維持健康的建議量（WHO 標準）。',
  ),
];

// ── Training Plans ─────────────────────────────────────────────────────────────

const JoggingPlan beginnerPlan = JoggingPlan(
  level: JoggingLevel.beginner,
  label: '初學者 4 週計畫',
  weeks: 4,
  description: '適合完全沒有跑步習慣的人。以走跑交替開始，讓身體慢慢適應前腳掌著地的技巧。',
  sessions: [
    JoggingWeek(week: 1, days: [
      JoggingSession(label: '第 1 天', durationMin: 10, walkBreakMin: 5,
          description: '超慢跑 5 分 → 走路 2 分 → 超慢跑 5 分'),
      JoggingSession(label: '第 3 天', durationMin: 10, walkBreakMin: 5,
          description: '超慢跑 5 分 → 走路 2 分 → 超慢跑 5 分'),
      JoggingSession(label: '第 5 天', durationMin: 12, walkBreakMin: 3,
          description: '超慢跑 6 分 → 走路 2 分 → 超慢跑 6 分'),
    ]),
    JoggingWeek(week: 2, days: [
      JoggingSession(label: '第 1 天', durationMin: 15, walkBreakMin: 3,
          description: '超慢跑 8 分 → 走路 2 分 → 超慢跑 7 分'),
      JoggingSession(label: '第 3 天', durationMin: 15, walkBreakMin: 3,
          description: '超慢跑 8 分 → 走路 2 分 → 超慢跑 7 分'),
      JoggingSession(label: '第 5 天', durationMin: 18, walkBreakMin: 2,
          description: '超慢跑 10 分 → 走路 2 分 → 超慢跑 8 分'),
    ]),
    JoggingWeek(week: 3, days: [
      JoggingSession(label: '第 1 天', durationMin: 20, walkBreakMin: 0,
          description: '持續超慢跑 20 分鐘（不休息）'),
      JoggingSession(label: '第 3 天', durationMin: 20, walkBreakMin: 0,
          description: '持續超慢跑 20 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 25, walkBreakMin: 0,
          description: '持續超慢跑 25 分鐘'),
    ]),
    JoggingWeek(week: 4, days: [
      JoggingSession(label: '第 1 天', durationMin: 25, walkBreakMin: 0,
          description: '持續超慢跑 25 分鐘'),
      JoggingSession(label: '第 3 天', durationMin: 30, walkBreakMin: 0,
          description: '持續超慢跑 30 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 30, walkBreakMin: 0,
          description: '持續超慢跑 30 分鐘'),
    ]),
  ],
);

const JoggingPlan intermediatePlan = JoggingPlan(
  level: JoggingLevel.intermediate,
  label: '進階 4 週計畫',
  weeks: 4,
  description: '已能連續超慢跑 30 分鐘。目標增加至每次 45–60 分鐘，提升有氧基礎。',
  sessions: [
    JoggingWeek(week: 1, days: [
      JoggingSession(label: '第 1 天', durationMin: 35, description: '超慢跑 35 分鐘'),
      JoggingSession(label: '第 3 天', durationMin: 35, description: '超慢跑 35 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 40, description: '超慢跑 40 分鐘'),
    ]),
    JoggingWeek(week: 2, days: [
      JoggingSession(label: '第 1 天', durationMin: 40, description: '超慢跑 40 分鐘'),
      JoggingSession(label: '第 3 天', durationMin: 40, description: '超慢跑 40 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 45, description: '超慢跑 45 分鐘'),
    ]),
    JoggingWeek(week: 3, days: [
      JoggingSession(label: '第 1 天', durationMin: 45, description: '超慢跑 45 分鐘'),
      JoggingSession(label: '第 3 天', durationMin: 45, description: '超慢跑 45 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 50, description: '超慢跑 50 分鐘'),
    ]),
    JoggingWeek(week: 4, days: [
      JoggingSession(label: '第 1 天', durationMin: 50, description: '超慢跑 50 分鐘'),
      JoggingSession(label: '第 3 天', durationMin: 55, description: '超慢跑 55 分鐘'),
      JoggingSession(label: '第 5 天', durationMin: 60, description: '超慢跑 60 分鐘 🎉'),
    ]),
  ],
);

// ── Benefits ───────────────────────────────────────────────────────────────────

const List<(String icon, String title, String detail)> benefits = [
  ('🔥', '高效燃脂', '在 Niko-Niko 配速下，身體主要燃燒脂肪而非糖原，是最高效的燃脂運動之一'),
  ('🦵', '保護關節', '前腳掌著地大幅降低衝擊力，膝蓋和髖關節負擔遠低於一般慢跑'),
  ('❤️', '提升心肺', '長時間低強度有氧能有效提升最大攝氧量（VO2max）和心肺功能'),
  ('🧠', '改善認知', '日本研究顯示超慢跑可增加大腦海馬迴體積，改善記憶力和認知功能'),
  ('💤', '改善睡眠', '規律超慢跑能調節自律神經、提升睡眠品質'),
  ('👴', '老少皆宜', '強度極低，60–80 歲長者也能安全進行，適合各年齡層'),
];
