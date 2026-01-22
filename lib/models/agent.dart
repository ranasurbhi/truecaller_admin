class Agent {
  final String id;
  final String name;
  final int totalCalls;
  final int connected;
  final int missed;
  final int avgDuration; // seconds
  final bool acceptingCalls;

  Agent({
    required this.id,
    required this.name,
    required this.totalCalls,
    required this.connected,
    required this.missed,
    required this.avgDuration,
    required this.acceptingCalls,
  });

  // 🔹 Derived status (UI-friendly)
  String get status => acceptingCalls ? "Active" : "Unavailable";

  // 🔹 Formatted duration
  String get avgDurationFormatted {
    final minutes = avgDuration ~/ 60;
    final seconds = avgDuration % 60;
    return "${minutes}m ${seconds}s";
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
  int parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return double.tryParse(v)?.round() ?? 0;
    if (v is double) return v.round();
    return 0;
  }

  return Agent(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    totalCalls: parseInt(json['totalCalls']),
    connected: parseInt(json['connectedCalls']),
    missed: parseInt(json['missedCalls']),
    avgDuration: parseInt(json['avgDuration']),
    acceptingCalls: false, // backend not sending yet
  );
}

}
