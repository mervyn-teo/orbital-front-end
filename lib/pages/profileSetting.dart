import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orbital/profile.dart';

class profileSettings extends StatefulWidget {
  const profileSettings({super.key});

  @override
  State<profileSettings> createState() => _profileSettingsState();
}

class _profileSettingsState extends State<profileSettings> {
  Profile profile = Profile("", "asd", 0, "", "");

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/default_profile.png"), // local filepath, default is a placeholder image
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              child: MaterialButton(
                color: Colors.amber,
                onPressed: () {}, // TODO: make the upload function
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                child: const Text("upload profile picture"),
                ),
            ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {profile.name = value;},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Name", ),),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  onChanged: (value) {profile.age = int.parse(value);},
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Age", ),),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  minLines: 5,
                  maxLines: 10,
                  onChanged: (value) {profile.bio = value;},
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Bio", ),),
              )
          ],
          ),
      )
      );
  }
}