sealed class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.timestamp,
    required this.durationSeconds,
  });

  final String id;
  final DateTime timestamp;
  final int durationSeconds;

  String get type;

  Map<String, dynamic> toJson();

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final logType = json['type'] as String;
    return switch (logType) {
      'focus' => FocusSession.fromJson(json),
      'sleep' => SleepSession.fromJson(json),
      _ => throw FormatException('Invalid activity log type: $logType'),
    };
  }
}

class FocusSession extends ActivityLog {
  const FocusSession({
    required super.id,
    required super.timestamp,
    required super.durationSeconds,
  });

  @override
  String get type => 'focus';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int,
        isUtc: true,
      ).toLocal(),
      durationSeconds: json['duration_seconds'] as int,
    );
  }

  FocusSession copyWith({
    String? id,
    DateTime? timestamp,
    int? durationSeconds,
  }) {
    return FocusSession(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode =>
      id.hashCode ^ timestamp.hashCode ^ durationSeconds.hashCode;
}

class SleepSession extends ActivityLog {
  const SleepSession({
    required super.id,
    required super.timestamp,
    required super.durationSeconds,
    required this.rating,
  });

  final String rating; // 'restless', 'neutral', 'restored'

  @override
  String get type => 'sleep';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
      'rating': rating,
    };
  }

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      id: json['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int,
        isUtc: true,
      ).toLocal(),
      durationSeconds: json['duration_seconds'] as int,
      rating: json['rating'] as String,
    );
  }

  SleepSession copyWith({
    String? id,
    DateTime? timestamp,
    int? durationSeconds,
    String? rating,
  }) {
    return SleepSession(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          durationSeconds == other.durationSeconds &&
          rating == other.rating;

  @override
  int get hashCode =>
      id.hashCode ^
      timestamp.hashCode ^
      durationSeconds.hashCode ^
      rating.hashCode;
}
