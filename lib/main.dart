import 'package:flutter/material.dart';

void main() {
  runApp(Home());
}

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
          children: [Text('Hello World'), Text('Bytebank'), Text('Tech 3')],
        ),
      ),
    );
  }
}
