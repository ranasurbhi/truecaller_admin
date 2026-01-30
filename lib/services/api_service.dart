// This ApiService is ONLY for WEB DASHBOARD

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/call_summary.dart';
import '../models/agent.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  // ===============================
  // FETCH WEB DASHBOARD DATA
  // ===============================
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    final response = await http.get(
      Uri.parse("$baseUrl/web/dashboard"),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer YOUR_TOKEN" // add later if needed
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch dashboard: ${response.statusCode}",
      );
    }
  }

  // ===============================
  // PARSE SUMMARY
  // ===============================
  static CallSummary parseSummary(Map<String, dynamic> data) {
    return CallSummary.fromJson(data["summary"]);
  }

  // ===============================
  // PARSE AGENTS
  // ===============================
  static List<Agent> parseAgents(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) => Agent.fromJson(e)).toList();
  }
  static Future<Map<String, dynamic>> fetchTeamMembers() async {
  final response = await http.get(
    Uri.parse("$baseUrl/web/users"),
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load team members");
  }
}

}
