import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

class loading extends StatefulWidget {
  const loading({super.key});

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  bool LoggedIn = false;

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/logo.png'), context);
    ImageProvider logo = const AssetImage('assets/logo.png');
    
    return Scaffold(
      body: FutureBuilder(
        future: loadingActions(), 
        builder: (BuildContext context, AsyncSnapshot snap) {
          WidgetsBinding.instance.addPostFrameCallback((_){
            if (!snap.hasError) {
              if (LoggedIn) {
                Navigator.popAndPushNamed(context, '/home');
              } else {
                Navigator.popAndPushNamed(context, '/login');
              }
          }
        });
        return Container(
          
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: logo,
                  width: 300,  // Adjust the size as needed
                  height: 300, // Adjust the size as needed
                ),
                const SizedBox(height: 5),// Add spacing between logo and spinner
                const SpinKitPouringHourGlass(
                  color: Colors.blueAccent,
                  size: 120.0,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }


  Future<bool> hasLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasLoggedIn') == null) {
      await prefs.setBool('hasLoggedIn', false);
      return false;
    } else {
      return prefs.getBool('hasLoggedIn')!;
    }
  }

  Future<void> geolocationPerms() async {  
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      showDialog(
          context: context, 
          builder: (context) {
            return  const AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10)
                )
                ),
                title: Text("Location permission required"),
                content: Text('this application requires your location permissions to function!\n\nGrant location permission for this app in the system settings'),
            );
          }
        ).then((val) async {
          await Geolocator.requestPermission();
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
            exit(0);
          }
        });
    }
  }

  Future<bool> loadingActions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('GPSLogging', true);

    // login state
    LoggedIn = await hasLoggedIn();

    // GPS perms
    await geolocationPerms();

    // always return true after everying has loaded
    return true;
  }
}