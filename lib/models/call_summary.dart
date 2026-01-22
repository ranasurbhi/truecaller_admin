class CallSummary {
  final int totalCalls;
  final int connectedCalls;
  final int missedCalls;
  final int avgDuration; // seconds

  CallSummary({
    required this.totalCalls,
    required this.connectedCalls,
    required this.missedCalls,
    required this.avgDuration,
  });

  factory CallSummary.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return double.tryParse(v)?.round() ?? 0;
      return 0;
    }

    return CallSummary(
      totalCalls: parse(json['totalCalls']),
      connectedCalls: parse(json['connectedCalls']),
      missedCalls: parse(json['missedCalls']),
      avgDuration: parse(json['avgDuration']),
    );
  }
}
