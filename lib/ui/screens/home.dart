import 'package:bytebank_flutter/routes.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
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
            ElevatedButton(
              child: Text("Cadastro"),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.signUp,
                );
              },
            ),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.signIn,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
