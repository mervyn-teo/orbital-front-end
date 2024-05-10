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
            Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => {Navigator.pop(context)}),
              ),
            Center(child: Container(
              margin: const EdgeInsets. fromLTRB(0, 40, 0, 0),
              child: Card(
                shape: const CircleBorder(),
                elevation: 4,
                child: CircleAvatar(
                  radius: 70,
                  child: Image(
                    height: 280,
                    width: 280,
                    image: NetworkImage(profile.pfp)),
                ),
              ))),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.name,
                          style: const TextStyle(fontSize: 36),)),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.age.toString(),
                          style: const TextStyle(fontSize: 24),)),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text(profile.bio,
                          style: const TextStyle(fontSize: 15),),
              ),
            ],
          ),
      ) 
    );
  }
}