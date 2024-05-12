// ignore_for_file: depend_on_referenced_packages, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:positiveme/home.dart';

import 'package:positiveme/boarding.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Comfortaa'),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: _loadNameFromStorage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while loading name from storage
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Once name is loaded, decide whether to show OnboardingScreen or HomeScreen
            final String? storedName = snapshot.data;
            if (storedName == null || storedName.isEmpty) {
              return const OnBoardPages();
            } else {
              return const HomeScreen();
            }
          }
        },
      ),
    );
  }

  Future<String?> _loadNameFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
}
