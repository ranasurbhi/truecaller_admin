class CallSummary {
  final int totalCalls;
  final int connected;
  final int missedCalls;

  CallSummary({
    required this.totalCalls,
    required this.connected,
    required this.missedCalls,
  });

  factory CallSummary.fromJson(Map<String, dynamic> json) {
  return CallSummary(
    totalCalls: int.tryParse(json["totalCalls"]?.toString() ?? "0") ?? 0,
    connected: int.tryParse(json["connected"]?.toString() ?? "0") ?? 0,
    missedCalls: int.tryParse(json["missedCalls"]?.toString() ?? "0") ?? 0,
  );
}


}
