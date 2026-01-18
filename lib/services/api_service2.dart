import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService2 {
  static const String baseUrl = "http://192.168.0.106:3000";

  /* =========================
     DASHBOARD STATS
  ========================= */
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await http.get(Uri.parse("$baseUrl/dashboard/stats"));
    final json = jsonDecode(res.body);
    return json['data'];
  }

  /* =========================
     GET ALL CAMPAIGNS
     (optionally agent-specific)
  ========================= */
  static Future<List<dynamic>> getCampaigns({int? agentId}) async {
    final uri = agentId == null
        ? Uri.parse("$baseUrl/campaigns")
        : Uri.parse("$baseUrl/campaigns?agentId=$agentId");

    final res = await http.get(uri);
    final json = jsonDecode(res.body);
    return json['data'];
  }

  /* =========================
     CREATE CAMPAIGN
  ========================= */
  static Future<Map<String, dynamic>> createCampaign(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse("$baseUrl/campaigns"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }

  /* =========================
     UPDATE CAMPAIGN STATUS
  ========================= */
  static Future<void> updateCampaignStatus(
      int campaignId, String status) async {
    await http.put(
      Uri.parse("$baseUrl/campaigns/$campaignId/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );
  }

  /* =========================
     GET LEADS FOR CAMPAIGN
  ========================= */
  static Future<List<dynamic>> getLeadsByCampaign(int campaignId) async {
    final res = await http.get(Uri.parse("$baseUrl/leads/campaign/$campaignId"));

    // Decode safely
    final Map<String, dynamic> jsonResponse = jsonDecode(res.body);

    if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
      return jsonResponse['data'];
    } else {
      throw Exception(jsonResponse['message'] ?? "Failed to fetch leads");
    }
  }


  /* =========================
     CREATE LEAD
  ========================= */
  static Future<Map<String, dynamic>> createLead(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leads"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    final json = jsonDecode(res.body);
    return json['data'];
  }
  // ================= UPLOAD LEADS (FINAL) =================
  static Future<Map<String, dynamic>> uploadLeadsBatch(
      int campaignId,
      List<Map<String, dynamic>> leads,
      ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leads/batch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "campaign_id": campaignId,
        "leads": leads,
      }),
    );

    return jsonDecode(res.body);
  }


}


