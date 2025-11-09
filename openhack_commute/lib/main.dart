import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:openhack_commute/screens/login_screen.dart'; // Make sure this path is correct
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const CommuteApp());
}

class CommuteApp extends StatelessWidget {
  const CommuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      // --- MODIFICATION: Replaced navigation with a PageRouteBuilder ---
      Navigator.pushReplacement(
        context,
        // This creates a fade transition instead of the default slide
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600), // Adjust speed
        ),
      );
      // --- END OF MODIFICATION ---
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- MODIFICARE: Folosim Stack pentru a pune imaginea de fundal ---
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Imaginea de fundal (folosește assets/bg.png sau o altă imagine mare)
          // Presupunând că ai o imagine de fundal locală numită 'bg_splash.jpg'
          Image.asset(
            'assets/bg.png', // ASIGURĂ-TE că ai acest fișier în assets/
            fit: BoxFit.cover,
            // Adăugăm un filtru pentru estompare și întunecare
            colorBlendMode: BlendMode.darken,
            color: Colors.black.withOpacity(0.6),
          ),
          
          // 2. Logo-ul (centrat)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'logo-hero',
                  child: Image.asset(
                    'assets/logo.png', // Logo-ul tău principal
                    width: 200.0,
                    height: 200.0,
                  ),
                ),
                // const SizedBox(height: 16),
                // const Text("Commute",
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 30,
                //         fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}