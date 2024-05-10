import 'package:flutter/material.dart';
import 'package:orbital/pages/loading.dart';
import 'package:orbital/pages/home.dart';


void main() => runApp(MaterialApp(
  initialRoute: '/home', // TODO: make home() run first for testing, remove for actual product
  routes: {
    '/': (context) => const loading(),
    '/home': (context) => const homePage(), 
  },
)
);




