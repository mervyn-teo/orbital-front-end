import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class loading extends StatefulWidget {
  const loading({super.key});

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/loadingwallpaper.png'), context);
    precacheImage(AssetImage('assets/logo.png'), context);
    ImageProvider loadedWallpaper = AssetImage('assets/loadingwallpaper.png');
    ImageProvider logo = AssetImage('assets/logo.png');
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
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: loadedWallpaper,
              fit: BoxFit.cover,
            ),
          ),

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: logo,
                  width: 300,  // Adjust the size as needed
                  height: 300, // Adjust the size as needed
                ),
                SizedBox(height: 5),// Add spacing between logo and spinner
                SpinKitPouringHourGlass(
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
      prefs.setBool('hasLoggedIn', false);
      return false;
    } else {
      return prefs.getBool('hasLoggedIn')!;
    }
  }
}