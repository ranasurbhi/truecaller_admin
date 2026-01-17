class CallSummary {
  final int totalCalls;
  final int connected;
  final int missedCalls;
  final dynamic _avgDuration;

  CallSummary({
    required this.totalCalls,
    required this.connected,
    required this.missedCalls,
    required dynamic avgDuration,
  }) : _avgDuration = avgDuration;

  // Null-safe getter for avgDuration
  double get avgDuration {
    if (_avgDuration == null) return 0.0;
    if (_avgDuration is int) return (_avgDuration as int).toDouble();
    if (_avgDuration is double) return _avgDuration as double;
    if (_avgDuration is String) return double.tryParse(_avgDuration) ?? 0.0;
    return 0.0;
  }

  // Formatted duration string
  String get avgDurationFormatted {
    final totalSeconds = avgDuration.toInt();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  factory CallSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CallSummary(
      totalCalls: parseInt(json['totalCalls']),
      connected: parseInt(json['connected']),
      missedCalls: parseInt(json['missedCalls']),
      avgDuration: json['avgDuration'],
    );
  }
}
