import 'package:bytebank_flutter/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // This widget is the root of your application.

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();

    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.signIn);
        return;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      home: Scaffold(
        appBar: AppBar(title: Text('Bytebank')),
        body: Column(
          children: [
            Text('Hello World'),
            Text('Bytebank'),
            Text('Tech 3'),
            ElevatedButton(child: Text("FAZER LOGOUT"), onPressed: _signOut),
          ],
        ),
      ),
    );
  }

  _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, Routes.signIn);
  }
}
