# 全方位健身 Fitness & Health App

A cross-platform Flutter fitness app covering weight training, stretching, super slow jogging, nutrition, intermittent fasting, and weekly training plans — available on **macOS, Android, and iOS**.

---

## Screenshots

| 重訓 | 超慢跑 | 訓練計畫 |
|------|--------|---------|
| Muscle-group filter chips + exercise cards with YouTube thumbnails | Niko-Niko pace calculator + metronome + ambient sounds | Weekly drag-and-drop planner + colour-coded calendar |

---

## Features

### 💪 重訓 (Weight Training)
- **9 muscle groups**: 胸 Chest · 背 Back · 臀 Glutes · 大腿前/後側 Quads/Hamstrings · 小腿 Calves · 手臂 Arms · 核心 Core
- Filter by muscle group, expand cards for step-by-step instructions, tips, and YouTube demo thumbnails
- Includes squats, deadlifts, hip thrusts, pull-ups, bench press, core exercises, and more

### 🧘 伸展 (Stretching)
- Same muscle-group filtering as training
- Each stretch shows hold duration, sets, and technique cues
- Video thumbnails for key stretches

### 🏃 超慢跑 (Super Slow Jogging)
Based on Prof. Hiroaki Tanaka's Slow Jogging method:
- **Niko-Niko pace calculator** — enter your age, get your optimal heart rate zone
- **Cadence metronome** — 5 synthesised tones (清脆/中音/大鼓/低拍/木魚), 150–200 BPM, generated in pure Dart (no audio assets)
- **Ambient sound library** — 8 curated sounds (rain, ocean, forest, crickets, café, white noise, lo-fi, 180 BPM beats), tap to open in YouTube
- 4-week beginner & intermediate training plans
- Technique tips (forefoot landing, cadence, Niko-Niko pace, posture, breathing)

### 🥗 營養 (Nutrition)
- Goal selector: 增肌 Muscle Gain · 減脂 Fat Loss · 減肥 Weight Loss · 斷食 Fasting
- Daily macro targets (calories, protein, carbs, fat) with per-goal strategy tips
- Sample calculations based on bodyweight

### ⏱️ 斷食 (Intermittent Fasting Timer)
- 5 fasting protocols: 16:8 · 18:6 · 20:4 · OMAD (23h) · 5:2
- Circular progress ring with real-time countdown
- 5:2 shows a contextual info card instead of a timer (weekly pattern, not hourly)
- Session result card on completion

### 📅 訓練計畫 (Training Plan + Calendar)
- Configure weekly activity frequency: 重訓 × N + 伸展 × N + 超慢跑 × N + 斷食 × N
- **Smart auto-assignment** distributes activities across the week with no same-day conflicts
- **Drag-and-drop weekly preview** — long-press any activity bubble to move it to another day
- **Colour-coded calendar** — each activity has its own colour (blue/green/orange/purple), larger day numbers, checkbox per day
- Tap any day → bottom sheet to mark complete / undo
- Weekly progress bar
- Data persisted via SharedPreferences

### 🗺️ 肌群圖 (Body Map)
- Interactive muscle-group selector
- Tabbed view: Weight Training / Stretching exercises for the selected muscle group

---

## Tech Stack

| Layer | Library |
|---|---|
| UI framework | Flutter 3.x (Material 3) |
| State management | flutter_riverpod |
| Navigation | go_router |
| Audio | just_audio (metronome), audioplayers |
| Calendar | table_calendar |
| Local storage | shared_preferences |
| URL launching | url_launcher |
| Animations | flutter_animate |
| Charts | fl_chart |

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.3.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Xcode (for macOS / iOS builds)
- Android Studio + SDK (for Android builds)

### Install & Run

```bash
git clone https://github.com/wapert/fitness-health.git
cd fitness-health

flutter pub get

# Run on macOS
flutter run -d macos

# Run on Android (device connected via USB)
flutter run -d android

# Run on iOS (requires Xcode signing setup)
flutter run -d ios
```

### Build Release APK (Android)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build for macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/fitness_health.app
```

---

## Project Structure

```
lib/
├── core/
│   ├── models/          # Exercise, MuscleGroup, Nutrition, Fasting, Jogging, TrainingPlan
│   ├── theme/           # Material 3 light + dark theme
│   └── constants/       # GoRouter configuration
├── features/
│   ├── training/        # 重訓 — exercises, filter screen, cards
│   ├── stretching/      # 伸展 — stretch routines
│   ├── jogging/         # 超慢跑 — pace calc, metronome, sounds, plans
│   ├── nutrition/       # 營養 — macro calculator
│   ├── fasting/         # 斷食 — interval fasting timer
│   ├── plan/            # 訓練計畫 — weekly planner + calendar
│   └── body_map/        # 肌群圖 — muscle group map
└── shared/
    └── widgets/         # MainShell (bottom nav), YoutubePlayer
```

---

## Roadmap

- [ ] USDA FoodData API integration for food search + barcode scanning
- [ ] Workout logging (sets / reps / weight history)
- [ ] Progress charts (bodyweight, 1RM trends)
- [ ] Interactive SVG body diagram
- [ ] Push notifications for fasting timer completion
- [ ] iOS App Store / Google Play release signing

---

## License

MIT — feel free to use, modify and distribute.
