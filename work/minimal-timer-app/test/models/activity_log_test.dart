import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dev_team_flutter/models/activity_log.dart';

void main() {
  group('ActivityLog Model Tests', () {
    test('FocusSession JSON round-trip', () {
      final session = FocusSession(
        id: 'test-focus-id',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          1600000000000,
          isUtc: true,
        ).toLocal(),
        durationSeconds: 1500,
      );

      final json = session.toJson();
      expect(json['type'], 'focus');
      expect(json['id'], 'test-focus-id');
      expect(json['duration_seconds'], 1500);

      final decoded = ActivityLog.fromJson(json);
      expect(decoded, isA<FocusSession>());
      expect(decoded.id, session.id);
      expect(decoded.durationSeconds, session.durationSeconds);
      expect(decoded.timestamp, session.timestamp);
      expect(decoded, session);
    });

    test('SleepSession JSON round-trip', () {
      final session = SleepSession(
        id: 'test-sleep-id',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          1600000000000,
          isUtc: true,
        ).toLocal(),
        durationSeconds: 28800,
        rating: 'restored',
      );

      final json = session.toJson();
      expect(json['type'], 'sleep');
      expect(json['id'], 'test-sleep-id');
      expect(json['duration_seconds'], 28800);
      expect(json['rating'], 'restored');

      final decoded = ActivityLog.fromJson(json);
      expect(decoded, isA<SleepSession>());
      expect(decoded.id, session.id);
      expect(decoded.durationSeconds, session.durationSeconds);
      expect(decoded.timestamp, session.timestamp);
      expect((decoded as SleepSession).rating, session.rating);
      expect(decoded, session);
    });

    test('ActivityLog throws FormatException for invalid type', () {
      final invalidJson = {
        'id': 'test-id',
        'type': 'invalid_type',
        'timestamp': 1600000000000,
        'duration_seconds': 100,
      };

      expect(() => ActivityLog.fromJson(invalidJson), throwsFormatException);
    });

    test('FocusSession copyWith works correctly', () {
      final session = FocusSession(
        id: 'id1',
        timestamp: DateTime.now(),
        durationSeconds: 600,
      );

      final copied = session.copyWith(id: 'id2', durationSeconds: 900);
      expect(copied.id, 'id2');
      expect(copied.timestamp, session.timestamp);
      expect(copied.durationSeconds, 900);
    });

    test('SleepSession copyWith works correctly', () {
      final session = SleepSession(
        id: 'id1',
        timestamp: DateTime.now(),
        durationSeconds: 600,
        rating: 'neutral',
      );

      final copied = session.copyWith(id: 'id2', rating: 'restored');
      expect(copied.id, 'id2');
      expect(copied.timestamp, session.timestamp);
      expect(copied.durationSeconds, 600);
      expect(copied.rating, 'restored');
    });
  });
}
