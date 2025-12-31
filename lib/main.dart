import 'package:flutter/material.dart';

import 'package:truecaller/screens/web/add_user.dart';

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
          // '/': (context) => Dashboard(),
          '/': (context) => AddUserWebScreen(),

          
        },
    );
  }
}

