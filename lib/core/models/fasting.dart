enum FastingProtocol {
  sixteen8('16:8', 16, '每日16小時斷食，8小時進食'),
  eighteen6('18:6', 18, '每日18小時斷食，6小時進食'),
  twenty4('20:4', 20, '戰士飲食法，20小時斷食'),
  omad('OMAD', 23, '一日一餐，23小時斷食'),
  fiveTwo('5:2', 0, '每週5天正常飲食，2天極低熱量'); // special case

  const FastingProtocol(this.label, this.fastHours, this.description);
  final String label;
  final int fastHours;
  final String description;
}

class FastingSession {
  const FastingSession({
    required this.protocol,
    required this.startTime,
    this.endTime,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? startTime;

  final FastingProtocol protocol;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime updatedAt;

  bool get isActive => endTime == null;

  Duration get elapsed => (endTime ?? DateTime.now()).difference(startTime);

  Duration get target => Duration(hours: protocol.fastHours);

  double get progress =>
      protocol.fastHours == 0 ? 0 : elapsed.inSeconds / target.inSeconds;

  Map<String, dynamic> toJson() => {
        'protocol': protocol.name,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory FastingSession.fromJson(Map<String, dynamic> json) {
    final startTime = DateTime.parse(json['startTime'] as String).toLocal();
    return FastingSession(
      protocol: FastingProtocol.values.byName(json['protocol'] as String),
      startTime: startTime,
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String).toLocal(),
      updatedAt: json['updatedAt'] == null
          ? startTime
          : DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}
