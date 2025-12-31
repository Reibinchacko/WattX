import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'live_readings_screen.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? "dummy-client-id.apps.googleusercontent.com" : null,
  scopes: ['email'],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F3ED),
        useMaterial3: true,
      ),
      home: const LiveReadingsScreen(meterId: "METER001"),
    );
  }
}
