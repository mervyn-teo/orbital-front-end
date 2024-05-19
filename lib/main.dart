import 'package:flutter/material.dart';
import 'package:orbital/pages/loading.dart';
import 'package:orbital/pages/home.dart';
import 'package:orbital/pages/login.dart';
import 'package:orbital/pages/register.dart';


void main() => runApp(MaterialApp(
  initialRoute: '/home', // TODO: make home() run first for testing, remove for actual product
  routes: {
    '/': (context) => const loading(),
    '/home': (context) => const homePage(),
    '/login': (context) => const login(),
    '/register': (context) => const register(),
  },
)
);




