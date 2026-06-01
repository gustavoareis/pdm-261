import 'package:flutter/material.dart';
import 'package:window_to_front/window_to_front.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Window To Front example')),
        body: Center(
          child: ElevatedButton(
            onPressed: WindowToFront.activate,
            child: const Text('Activate window'),
          ),
        ),
      ),
    );
  }
}
