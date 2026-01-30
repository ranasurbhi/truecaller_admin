class Agent {
  final int id;
  final String name;
  final String status;
  final int totalCalls;
  final int connected;
  final int missed;

  Agent({
    required this.id,
    required this.name,
    required this.status,
    required this.totalCalls,
    required this.connected,
    required this.missed,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
  return Agent(
    id: int.parse(json["id"].toString()),
    name: json["name"] ?? "",
    status: json["status"] ?? "Offline",
    totalCalls: int.parse(json["totalCalls"].toString()),
    connected: int.parse(json["connected"].toString()),
    missed: int.parse(json["missed"].toString()),
  );
}
}
