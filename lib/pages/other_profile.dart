import 'package:flutter/material.dart';
import 'package:orbital/Profile.dart';

class otherProfile extends StatelessWidget {
  const otherProfile({super.key, required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Center(child: Container(
              margin: EdgeInsets. fromLTRB(0, 40, 0, 0),
              child: Card(
                shape: const CircleBorder(),
                elevation: 4,
                child: CircleAvatar(
                  radius: 70,
                  child: Image(
                    image: AssetImage(profile.pfp)),
                ),
              ))),
            Container(
              margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.name,
                          style: TextStyle(fontSize: 36),)),
            Container(
              margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.age.toString(),
                          style: TextStyle(fontSize: 24),)),
            Container(
              margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.bio,
                          style: TextStyle(fontSize: 15),),
              ),
            ],
          ),
      ) 
    );
  }
}