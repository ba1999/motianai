import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motionai/color_schemes.dart';
import 'package:motionai/pages/home_page.dart';
import 'package:motionai/pages/training_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter widgets are initialized
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation
        .portraitUp, // Locks the device orientation to portrait mode
  ]);
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform); // Initializes Firebase with default settings based on the platform (iOS/Android)

  runApp(const MyApp()); // Runs the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables the debug banner
      title: 'MotionAI', // Title of the app
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme), // Light theme settings
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme), // Dark theme settings
      home: HomePage(), // Sets the home page of the app
    );
  }
}
