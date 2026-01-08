import 'package:flutter/material.dart';

class AgentAvatar extends StatelessWidget {
  final String name;
  final String? profileImage;
  final double size;

  const AgentAvatar({
    super.key,
    required this.name,
    this.profileImage,
    this.size = 36,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
      (profileImage != null && profileImage!.isNotEmpty)
          ? NetworkImage(
        "http://192.168.0.105:3000/uploads/$profileImage",
      )
          : null,
      child: (profileImage == null || profileImage!.isEmpty)
          ? Text(
        _getInitials(name),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      )
          : null,
    );
  }
}
