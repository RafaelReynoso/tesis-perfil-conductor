import 'package:flutter/material.dart';
import './components/navigation_bar.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Tesis_Conductor",
      debugShowCheckedModeBanner: false,
      home: Barra_Navegacion(),
    );
  }
}