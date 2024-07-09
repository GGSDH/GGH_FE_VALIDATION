import 'package:flutter/material.dart';
import 'package:ggh_fe_valdation/screens/photo_picker_screen.dart';
import 'package:ggh_fe_valdation/screens/scan_gallery_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GGH FE VALIDATION',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GGH FE VALIDATION'),
        ),
        body: const ScanGalleryScreen(),
      ),
    );
  }
}
