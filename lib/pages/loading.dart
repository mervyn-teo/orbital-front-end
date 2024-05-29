import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loading extends StatefulWidget {
  const loading({super.key});

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: hasLoggedIn(), 
        builder: (BuildContext context, AsyncSnapshot snap) {
          WidgetsBinding.instance.addPostFrameCallback((_){
            if (snap.hasData) {
            bool hasLoggedIn = snap.data;
            if (hasLoggedIn) {
              Navigator.popAndPushNamed(context, '/home');
            } else {
              Navigator.popAndPushNamed(context, '/login');
            }
          }
        });
          return const Text('loading');
        }),
    );
  }

  Future<bool> hasLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasLoggedIn') == null) {
      prefs.setBool('hasLoggedIn', false);
      return false;
    } else {
      return prefs.getBool('hasLoggedIn')!;
    }
  }
}