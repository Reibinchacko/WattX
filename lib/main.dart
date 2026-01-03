import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? "dummy-client-id.apps.googleusercontent.com" : null,
  scopes: ['email'],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: If you encounter database errors, ensure your Firebase Console
  // has Realtime Database enabled and the URL is correct.
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
