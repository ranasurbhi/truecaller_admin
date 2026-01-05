class Agent {
  final int id;
  final String name;
  final int totalCalls;
  final int connected;
  final int missed;
  final dynamic _avgDuration;
  final String status;

  Agent({
    required this.id,
    required this.name,
    required this.totalCalls,
    required this.connected,
    required this.missed,
    required dynamic avgDuration,
    this.status = "Unknown",
  }) : _avgDuration = avgDuration;

  // Null-safe getter for avgDuration
  double get avgDuration {
    if (_avgDuration == null) return 0.0;
    if (_avgDuration is int) return (_avgDuration as int).toDouble();
    if (_avgDuration is double) return _avgDuration as double;
    if (_avgDuration is String) return double.tryParse(_avgDuration) ?? 0.0;
    return 0.0;
  }


  String get avgDurationFormatted {
    final totalSeconds = (avgDuration * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Agent(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      totalCalls: parseInt(json['totalCalls']),
      connected: parseInt(json['connected']),
      missed: parseInt(json['missed']),
      avgDuration: json['avgDuration'],
      status: json['status'] ?? "Unknown",
    );
  }
}
