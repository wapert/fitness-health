# 全方位健身 App — Setup

## 1. Install Flutter

```bash
# Install via Homebrew (recommended on macOS)
brew install --cask flutter

# Verify
flutter doctor
```

## 2. Install dependencies

```bash
cd /Users/macbookair/Fitness-health
flutter pub get
```

## 3. Run (choose platform)

```bash
flutter run -d macos       # macOS desktop
flutter run -d ios         # iOS Simulator
flutter run -d android     # Android emulator
flutter run -d chrome      # Web (for testing)
```

## 4. Generate code (Riverpod / Drift / Freezed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Project structure

```
lib/
├── core/
│   ├── models/          # Exercise, MuscleGroup, Nutrition, Fasting
│   ├── theme/           # Light + dark Material 3 theme
│   └── constants/       # GoRouter config
├── features/
│   ├── training/        # 重訓 screens + exercise data
│   ├── stretching/      # 伸展 screens + stretch data
│   ├── nutrition/       # 飲食營養 screen + macro calculator
│   ├── fasting/         # 斷食 timer screen
│   └── body_map/        # Interactive muscle-group map
└── shared/
    └── widgets/         # MainShell (bottom nav)
```

## Next steps

- [ ] Add USDA FoodData Central API integration for food search
- [ ] Add local Drift database for workout & meal logging
- [ ] Replace body-map grid with interactive SVG illustration
- [ ] Add progress charts (fl_chart) for weight / reps over time
- [ ] Add video embeds via chewie + video_player
- [ ] Add fasting push notifications (flutter_local_notifications)
- [ ] Localization: Traditional Chinese + English
