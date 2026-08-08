import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;
import '../../../core/models/muscle_group.dart';

/// Which side of the body actually shows each muscle group. Used so that
/// selecting a group (e.g. from the chip row below the diagram) switches
/// the diagram to the side where it's actually visible, instead of leaving
/// the user on a view where nothing lights up.
const Map<MuscleGroup, bool> muscleGroupIsFront = {
  MuscleGroup.chest: true,
  MuscleGroup.back: false,
  MuscleGroup.glutes: false,
  MuscleGroup.quads: true,
  MuscleGroup.hamstrings: false,
  MuscleGroup.calves: false,
  MuscleGroup.biceps: true,
  MuscleGroup.triceps: false,
  MuscleGroup.shoulders: true,
  MuscleGroup.core: true,
};

/// Maps a package muscle to this app's (coarser) MuscleGroup.
MuscleGroup? _appGroupOf(atlas.MuscleInfo m) {
  switch (m.group) {
    case atlas.MuscleGroup.chest:
      return MuscleGroup.chest;
    case atlas.MuscleGroup.back:
      return MuscleGroup.back;
    case atlas.MuscleGroup.glutes:
      return MuscleGroup.glutes;
    case atlas.MuscleGroup.hamstrings:
      return MuscleGroup.hamstrings;
    case atlas.MuscleGroup.shoulders:
      return MuscleGroup.shoulders;
    case atlas.MuscleGroup.core:
      return MuscleGroup.core;
    case atlas.MuscleGroup.arms:
      final id = m.id;
      if (id.contains('triceps') || id.contains('anconeus')) {
        return MuscleGroup.triceps;
      }
      return MuscleGroup.biceps; // biceps + forearm flexors/extensors
    case atlas.MuscleGroup.legs:
      final id = m.id;
      if (id.contains('gastrocnemius') ||
          id.contains('tibialis') ||
          id.contains('fibularis') ||
          id.contains('hallucis') ||
          id.contains('digitorum')) {
        return MuscleGroup.calves;
      }
      return MuscleGroup.quads; // vastus / rectus femoris / sartorius
    case atlas.MuscleGroup.adductors:
    case atlas.MuscleGroup.neck:
      return null;
  }
}

/// Interactive anatomical muscle map (front/back) built on flutter_body_atlas.
/// Tapping a muscle selects the matching app [MuscleGroup]; the current
/// selection is highlighted. SVG muscle art © Ryan Graves (CC BY 4.0).
///
/// `front`/`onFrontChanged` are controlled by the parent so that selecting a
/// muscle group from OUTSIDE the diagram (e.g. the chip row) can switch to
/// whichever side actually shows it. Tapping the diagram itself never needs
/// to change sides — whatever was tapped is, by definition, already visible
/// on the current side.
class MuscleMap extends StatelessWidget {
  const MuscleMap({
    super.key,
    required this.front,
    required this.onFrontChanged,
    required this.selected,
    required this.onSelect,
  });

  final bool front;
  final ValueChanged<bool> onFrontChanged;
  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup> onSelect;

  // "進擊的巨人" exposed-muscle look: paint the whole figure in anatomical
  // reds (varied per group for depth); the selected group glows gold.
  static const _highlightColor = Color(0xFFFFC93C); // glowing selected muscle

  static const Map<atlas.MuscleGroup, Color> _muscleReds = {
    atlas.MuscleGroup.chest:      Color(0xFFB23A3A),
    atlas.MuscleGroup.back:       Color(0xFF8E2A2A),
    atlas.MuscleGroup.shoulders:  Color(0xFFC0453A),
    atlas.MuscleGroup.arms:       Color(0xFFA83232),
    atlas.MuscleGroup.core:       Color(0xFFB8443C),
    atlas.MuscleGroup.glutes:     Color(0xFF9B2C2C),
    atlas.MuscleGroup.legs:       Color(0xFF95302E),
    atlas.MuscleGroup.hamstrings: Color(0xFF7E2525),
    atlas.MuscleGroup.adductors:  Color(0xFFA23A34),
    atlas.MuscleGroup.neck:       Color(0xFFC05248),
  };

  Map<atlas.MuscleInfo, Color?> _colorMapping() {
    final map = <atlas.MuscleInfo, Color?>{};
    for (final m in atlas.MuscleCatalog.all) {
      final g = _appGroupOf(m);
      map[m] = (selected != null && g == selected)
          ? _highlightColor
          : (_muscleReds[m.group] ?? const Color(0xFF9B2C2C));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final mapping = _colorMapping();

    return Column(
      children: [
        // ── Front / back toggle ────────────────────────────────────────
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('正面'), icon: Icon(Icons.accessibility_new)),
            ButtonSegment(value: false, label: Text('背面'), icon: Icon(Icons.accessibility)),
          ],
          selected: {front},
          onSelectionChanged: (s) => onFrontChanged(s.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 8),

        // ── Anatomical diagram ─────────────────────────────────────────
        SizedBox(
          height: 260,
          child: atlas.BodyAtlasView<atlas.MuscleInfo>(
            view: front
                ? atlas.AtlasAsset.musclesFront
                : atlas.AtlasAsset.musclesBack,
            resolver: const atlas.MuscleResolver(),
            colorMapping: mapping,
            hoverColor: (c) => c.withValues(alpha: 0.6),
            onTapElement: (info) {
              final g = _appGroupOf(info);
              if (g != null) onSelect(g);
            },
          ),
        ),
      ],
    );
  }
}
