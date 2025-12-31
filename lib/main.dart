import 'package:flutter/material.dart';

import 'package:truecaller/screens/web/add_user.dart';
import 'package:truecaller/screens/web/dashboard.dart';

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
        routes: {
            '/': (context) => const DashboardScreen(),
            '/add-user': (context) => const AddUserWebScreen(),
        },
    );
  }
}

