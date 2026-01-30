class TeamMember {
  final int id;
  final String name;
  final String role;
  final String email;
  final String joiningDate;
  final String status;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.joiningDate,
    required this.status,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: int.parse(json["id"].toString()),
      name: json["name"] ?? "",
      role: json["role"] ?? "",
      email: json["email"] ?? "",
      joiningDate: json["joiningDate"] ?? "",
      status: json["status"] ?? "Offline",
    );
  }
}
