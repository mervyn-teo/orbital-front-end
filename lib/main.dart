import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orbital/pages/chat.dart';
import 'package:orbital/pages/loading.dart';
import 'package:orbital/pages/home.dart';
import 'package:orbital/pages/login.dart';
import 'package:orbital/pages/profileSetting.dart';
import 'package:orbital/pages/register.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// testaccount
// u: testtes123@abc.com
// p: asdfghj
// id: 98

var routes = {
    '/': (context) => const loading(),
    '/home': (context) => const homePage(),
    '/login': (context) => const login(),
    '/register': (context) => const register(),
    '/profilesetting': (context) => const profileSettings(),
    '/chat': (context) => const myChat(),
  };
  
void main() {
  runApp(MaterialApp(
  initialRoute: '/', 
  routes: routes,
  )); 
  

  // upload location
    Timer.periodic(const Duration(seconds: 5), (timer) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('hasLoggedIn') != null && prefs.getBool('hasLoggedIn')! && prefs.getBool('GPSLogging')!) {
      //upload geolocation data
      Position currPos = await Geolocator.getCurrentPosition();
      JsonDecoder decoder = const JsonDecoder();

      final response = await http.put(Uri.parse('http://13.231.75.235:8080/updateGeog'),
      body: jsonEncode({
        "id": prefs.getString('id'),
        "lat": currPos.latitude,
        "long": currPos.longitude,
      }))
      .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        // not ok
        throw Exception(response.reasonPhrase);
      }
    }

  });

  }