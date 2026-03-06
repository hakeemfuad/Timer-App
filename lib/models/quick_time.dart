class QuickTime {
  final int minutes;
  final int seconds;

  const QuickTime(this.minutes, this.seconds);

  String get label {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  int get totalSeconds => minutes * 60 + seconds;

  Map<String, dynamic> toJson() => {
        'minutes': minutes,
        'seconds': seconds,
      };

  factory QuickTime.fromJson(Map<String, dynamic> json) => QuickTime(
        json['minutes'] as int,
        json['seconds'] as int,
      );

  static const List<QuickTime> defaults = [
    QuickTime(0, 30),
    QuickTime(1, 0),
    QuickTime(2, 0),
    QuickTime(3, 0),
  ];
}
