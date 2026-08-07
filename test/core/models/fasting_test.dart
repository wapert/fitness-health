import 'package:fitness_health/core/models/fasting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastingSession persistence', () {
    test('restores an active session with its original timestamps', () {
      final start = DateTime.parse('2026-08-04T08:30:00+08:00');
      final updated = DateTime.parse('2026-08-04T08:31:00+08:00');
      final session = FastingSession(
        protocol: FastingProtocol.eighteen6,
        startTime: start,
        updatedAt: updated,
      );

      final restored = FastingSession.fromJson(session.toJson());

      expect(restored.protocol, FastingProtocol.eighteen6);
      expect(restored.startTime.isAtSameMomentAs(start), isTrue);
      expect(restored.updatedAt.isAtSameMomentAs(updated), isTrue);
      expect(restored.endTime, isNull);
      expect(restored.isActive, isTrue);
    });

    test('restores a completed session and its elapsed duration', () {
      final start = DateTime.parse('2026-08-03T18:00:00+08:00');
      final end = start.add(const Duration(hours: 16, minutes: 12));
      final session = FastingSession(
        protocol: FastingProtocol.sixteen8,
        startTime: start,
        endTime: end,
        updatedAt: end,
      );

      final restored = FastingSession.fromJson(session.toJson());

      expect(restored.isActive, isFalse);
      expect(restored.endTime!.isAtSameMomentAs(end), isTrue);
      expect(restored.elapsed, const Duration(hours: 16, minutes: 12));
      expect(restored.progress, greaterThan(1));
    });

    test('reads records created before updatedAt was introduced', () {
      final restored = FastingSession.fromJson({
        'protocol': 'fiveTwo',
        'startTime': '2026-08-04T00:00:00.000Z',
        'endTime': null,
      });

      expect(restored.updatedAt, restored.startTime);
      expect(restored.protocol, FastingProtocol.fiveTwo);
      expect(restored.isActive, isTrue);
    });
  });
}
