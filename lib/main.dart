import 'package:bytebank_flutter/routes.dart';
import 'package:bytebank_flutter/ui/screens/bytebank.dart';
import 'package:bytebank_flutter/ui/screens/home.dart';
import 'package:bytebank_flutter/ui/screens/sign-in.dart';
import 'package:bytebank_flutter/ui/screens/sign-up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ByteBank",
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => BytebankApp(),
        Routes.signUp: (context) => SignUp(),
        Routes.signIn: (context) => SignIn(),
      },
    );
  }
}
