//This api service is for dashboard call stats only

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/call_summary.dart';
import '../models/agent.dart';

class ApiService {
  static const baseUrl = "http://192.168.0.105:3000";

  // Fetch combined dashboard data
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    final response = await http.get(Uri.parse("$baseUrl/call-stats/summary"));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch dashboard: ${response.statusCode}");
    }
  }

  static CallSummary parseSummary(Map<String, dynamic> json) {
    return CallSummary.fromJson(json);
  }

  static List<Agent> parseAgents(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => Agent.fromJson(e)).toList();
    }
    return [];
  }
}
