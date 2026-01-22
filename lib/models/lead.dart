class Lead {
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final String telecaller;
  final String lastActivity;

  Lead({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.status,
    required this.telecaller,
    required this.lastActivity,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'New Lead',
      telecaller: json['telecaller']?.toString() ?? 'Unassigned',
      lastActivity: json['last_activity']?.toString() ?? '-',
    );
  }
}
