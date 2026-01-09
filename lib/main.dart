import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/add_user.dart';
import 'package:truecaller/screens/web/agent_performance.dart';
import 'package:truecaller/screens/web/campaign.dart';
import 'package:truecaller/screens/web/campaign_lead.dart';
import 'package:truecaller/screens/web/create_template.dart';
import 'package:truecaller/screens/web/dashboard.dart';
import 'package:truecaller/screens/web/edit_user.dart';
import 'package:truecaller/screens/web/leads_activity_log.dart';
import 'package:truecaller/screens/web/login_screen.dart';
import 'package:truecaller/screens/web/team_member.dart';
import 'package:truecaller/screens/web/template_list.dart';
import 'package:truecaller/screens/web/upload_leads.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
       initialRoute: '/login',
        routes: {
            '/': (context) =>  DashboardScreen(),
            '/login': (context) => const LoginWebScreen(),
            '/add-user': (context) => const AddUserWebScreen(),
            '/team-member': (context) =>  TeamMembersScreen(),
            '/edit-user': (context) =>  EditUserScreen(),
            '/campaign-lead': (context) =>  CampaignLeadsScreen(),
            '/campaign': (context) =>  CampaignManagementWebScreen(),
            '/activity-log': (context) =>  LeadActivityScreen(),
            '/msg-template': (context) =>  MessageTemplatesScreen(),
            '/create-template': (context) =>  CreateWhatsappTemplateScreen(),
            '/upload-leads': (context) =>  UploadLeadsScreen(),
            '/agent-performance': (context) =>  AgentPerformanceScreen(),


        },
    );
  }
}

