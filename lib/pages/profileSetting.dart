import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:orbital/profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class profileSettings extends StatefulWidget {
  const profileSettings({super.key});

  @override
  State<profileSettings> createState() => _profileSettingsState();
}

class _profileSettingsState extends State<profileSettings> {
  Profile profile = Profile("", "", 0, "", "https://static-00.iconduck.com/assets.00/profile-circle-icon-256x256-cm91gqm2.png");

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    profile.id = arguments['id'].toString();
    return  SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage("https://static-00.iconduck.com/assets.00/profile-circle-icon-256x256-cm91gqm2.png"), // local filepath, default is a placeholder image
                // foregroundImage:  TODO: this suppose to be set to uploaded image
              ),
            ),
            // Container(
            //   margin: const EdgeInsets.all(20),
            //   child: MaterialButton(
            //     color: Colors.amber,
            //     onPressed: () {
            //       changeProfile();
            //     }, // TODO: make the upload function
            //     shape: const RoundedRectangleBorder(
            //       borderRadius: BorderRadius.all(Radius.circular(6))
            //     ),
            //     child: const Text("upload profile picture"),
            //     ),
            // ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
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
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
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
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  minLines: 5,
                  maxLines: 10,
                  onChanged: (value) {profile.bio = value;},
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Bio", ),),
              ),
              Container(
              margin: const EdgeInsets.all(20),
              child: MaterialButton(
                color: Colors.amber,
                onPressed: () {
                  profileCreation();
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                child: const Text("done"),
                ),
            ),
          ],
          ),
      )
      );
  }

  // this is for profile pic stuff
  // TODO: implement this

  // Future<File> changeProfile() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     File ret = File(image.path);
  //     return ret;
  //   }
  //   return File("asset/default_profile.png");
  // } 

  // Future<String> uploadProfile() {
  //   return;
  // }
  

  Future<void> profileCreation() async {
    if (profile.name == "" || profile.age == 0 || profile.bio == "" || profile.pfp == "" ) {
      showDialog(
        context: context, 
        builder: (context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20)
              )
              ),
              title: Text("Check your information!"),
              content: Text("please make sure all option are filled"),
          );
      }
      );
    } else {
      var responses = await addProfile();
      if (responses['err_msg'] != "ok") {
        showDialog(
        context: context, 
        builder: (context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20)
              )
              ),
              title: Text("Profile creation failed!"),
              content: Text("please try again!"),
          );
      }
      );
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', profile.name);
        await prefs.setString('bio', profile.bio);
        await prefs.setInt('age', profile.age);
        await prefs.setString('id', profile.id);
        await prefs.setString('pfp', profile.pfp);
        Navigator.popAndPushNamed(context, '/home');
      }
    }
  }

  Future<Map<String, dynamic>> addProfile() async {
    JsonDecoder decoder = const JsonDecoder();
    String retStatus = "";

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/profiles'),
      body: jsonEncode({
        "id": profile.id,
        "name": profile.name,
        "age": profile.age,
        "bio": profile.bio,
        "pfp": profile.pfp
      }))
      .timeout(const Duration(seconds: 5));
      
      Map<String, dynamic> converted = decoder.convert(response.body);

    return converted;
  }
}