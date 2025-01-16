class RankingRecord {
  final String difficulty;
  final Duration time;
  final DateTime date;
  final String nickname;

  const RankingRecord({
    required this.difficulty,
    required this.time,
    required this.date,
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'time': time.inSeconds,
      'date': date.toIso8601String(),
      'nickname': nickname,
    };
  }

  factory RankingRecord.fromJson(Map<String, dynamic> json) {
    return RankingRecord(
      difficulty: json['difficulty'],
      time: Duration(seconds: json['time']),
      date: DateTime.parse(json['date']),
      nickname: json['nickname'] ?? 'Unknown',
    );
  }
} 