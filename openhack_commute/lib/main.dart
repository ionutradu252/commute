import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_player/video_player.dart'; // 1. Importă pachetul video
import 'package:openhack_commute/screens/login_screen.dart';
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

// --- AICI ÎNCEPE MODIFICAREA ---
class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    // 2. Inițializează controller-ul video
    _controller = VideoPlayerController.asset('assets/loading.mp4')
      ..initialize().then((_) {
        // Asigură-te că widget-ul este construit după ce videoclipul e gata
        setState(() {
          _videoInitialized = true;
        });
        _controller.play(); // Pornește videoclipul
      });

    // 3. Adaugă un listener pentru a naviga când se termină
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    // Verifică dacă videoclipul s-a terminat
    if (_controller.value.position >= _controller.value.duration && _videoInitialized) {
      // Oprește listener-ul ca să nu navigheze de mai multe ori
      _controller.removeListener(_videoListener); 
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    // Folosim tranziția ta cu Fade pe care o aveai deja
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    // 4. Curăță resursele
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundal negru
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 5. Afișează videoclipul sau un spinner
          if (_videoInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          
          // (Opțional) Poți adăuga logo-ul Hero peste videoclip, dacă dorești
          // Center(
          //   child: Hero(
          //     tag: 'logo-hero',
          //     child: Image.asset(
          //       'assets/logo.png',
          //       width: 200.0,
          //       height: 200.0,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
// --- SFÂRȘITUL MODIFICĂRII ---