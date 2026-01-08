import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/add_user.dart';
import 'package:truecaller/screens/web/campaign.dart';
import 'package:truecaller/screens/web/campaign_lead.dart';
import 'package:truecaller/screens/web/create_template.dart';
import 'package:truecaller/screens/web/dashboard.dart';
import 'package:truecaller/screens/web/edit_user.dart';
import 'package:truecaller/screens/web/leads_activity_log.dart';
import 'package:truecaller/screens/web/team_member.dart';
import 'package:truecaller/screens/web/create_campaign_screen.dart';
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Campaign Leads screen with required parameters
        if (settings.name == '/campaign-lead') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CampaignLeadsScreen(
              campaignId: args['campaignId'],
              campaignName: args['campaignName'],
            ),
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => const DashboardScreen());
          case '/add-user':
            return MaterialPageRoute(
                builder: (context) => const AddUserWebScreen());
          case '/team-member':
            return MaterialPageRoute(builder: (context) => TeamMembersScreen());
          case '/create-campaign':
            return MaterialPageRoute(
                builder: (context) => const CreateCampaignScreen());
          case '/edit-user':
            return MaterialPageRoute(builder: (context) => EditUserScreen());
          case '/campaign':
            return MaterialPageRoute(
                builder: (context) => const CampaignManagementWebScreen());
          case '/msg-template':
            return MaterialPageRoute(
                builder: (context) => MessageTemplatesScreen());
          case '/create-template':
            return MaterialPageRoute(
                builder: (context) => CreateWhatsappTemplateScreen());
          case '/upload-leads':
            return MaterialPageRoute(
                builder: (context) => UploadLeadsScreen());
          default:
            return null;
        }
      },
    );
  }
}
