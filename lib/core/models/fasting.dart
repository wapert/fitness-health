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
  });

  final FastingProtocol protocol;
  final DateTime startTime;
  final DateTime? endTime;

  bool get isActive => endTime == null;

  Duration get elapsed => (endTime ?? DateTime.now()).difference(startTime);

  Duration get target => Duration(hours: protocol.fastHours);

  double get progress =>
      protocol.fastHours == 0 ? 0 : elapsed.inSeconds / target.inSeconds;
}
