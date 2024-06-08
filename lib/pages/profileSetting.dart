import 'dart:convert';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
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
  // profile to upload
  Profile profile = Profile("", "", 0, "", "https://static-00.iconduck.com/assets.00/profile-circle-icon-256x256-cm91gqm2.png");
  XFile? imageFile = XFile("assets/default_profile.png");  
  late bool isFirstTime;
  bool isPfpChanged = false;
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    profile.id = arguments['id'];
    return  FutureBuilder(
      future: getPreferences(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        
      switch (snapshot.connectionState) {
      case ConnectionState.none: return const Text('Press button to start');
      case ConnectionState.waiting: return const Text('Awaiting result...');
      default:
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          
          var pref = snapshot.data;

          TextEditingController nameController = TextEditingController();
          TextEditingController ageController = TextEditingController();
          TextEditingController bioController = TextEditingController();

          if (pref.getString('id') != null) {
            // there are shared info
            profile.age = pref.getInt('age') ?? 0;
            profile.bio = pref.getString('bio') ?? "";
            profile.name = pref.getString('name') ?? "";
            profile.pfp = pref.getString('pfp') ?? "";

            ageController.text = pref.getInt('age').toString();
            bioController.text = pref.getString('bio');
            nameController.text = pref.getString('name');
            profile.pfp = pref.getString('pfp');
          } 


          return SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profile.pfp), // local filepath, default is a placeholder image
                  foregroundImage: FileImage(File(imageFile!.path)),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: MaterialButton(
                  color: Colors.amber,
                  onPressed: () async {
                    imageFile = await changeProfile();
                    setState(() {
                      imageFile = imageFile;
                    });
                  }, // TODO: make the upload function
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                  child: const Text("upload profile picture"),
                  ),
              ),
                Container(
                  margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {profile.name = value;},
                    controller: nameController,
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
                    controller: ageController,
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
                    controller: bioController,
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
      }
    } 
    );
  }

  // TODO: implement this
  Future<SharedPreferences> getPreferences() async {
    var pref = await SharedPreferences.getInstance();
    isFirstTime = pref.getString('id') == null;
    return pref;
  }

  // this is for profile pic stuff
  Future<XFile> changeProfile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        compressFormat: ImageCompressFormat.jpg
      );
      
      if (croppedFile == null) return XFile("asset/default_profile.png");
      isPfpChanged = true;
      return XFile(croppedFile.path);
    }

    return XFile("asset/default_profile.png");
  } 
  

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
      var responses = isFirstTime? await addProfile() : await editProfile();
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

  Future<void> uploadPfp(String id) async {
    var body = await imageFile!.readAsBytes();
    var resonse = await http.put(
      Uri.parse('https://3x4ub88a07.execute-api.ap-northeast-1.amazonaws.com/orbital/orbital-media/${id}.jpg'), 
      headers: {
        'Content-Type': 'image/jpg',
      },
      body: body
    );

    if (resonse.statusCode != 200) {
      // error
      throw Exception(resonse.reasonPhrase);
    }
  }

    Future<Map<String, dynamic>> editProfile() async {
 
    JsonDecoder decoder = const JsonDecoder();
    String retStatus = "";

    try {
      if (isPfpChanged) {
        await uploadPfp(profile.id);
      }

      profile.pfp = 'https://orbital-media.s3.ap-northeast-1.amazonaws.com/${profile.id}.jpg';
    } catch (e) {
      profile.pfp = 'https://static-00.iconduck.com/assets.00/profile-circle-icon-256x256-cm91gqm2.png';
    }

    final response = await http.patch(Uri.parse('http://13.231.75.235:8080/profile'),
      body: jsonEncode({
        "id": profile.id,
        "name": profile.name,
        "age": profile.age,
        "bio": profile.bio,
        "pfp": profile.pfp
      }))
      .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        // not ok
        throw Exception(response.reasonPhrase);
      }
      Map<String, dynamic> converted = decoder.convert(response.body);

    return converted;
  }

  Future<Map<String, dynamic>> addProfile() async {
    JsonDecoder decoder = const JsonDecoder();
    String retStatus = "";

    try {
      await uploadPfp(profile.id);
      profile.pfp = 'https://orbital-media.s3.ap-northeast-1.amazonaws.com/${profile.id}.jpg';
    } catch (e) {
      profile.pfp = 'https://static-00.iconduck.com/assets.00/profile-circle-icon-256x256-cm91gqm2.png';
    }

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/profiles'),
      body: jsonEncode({
        "id": profile.id,
        "name": profile.name,
        "age": profile.age,
        "bio": profile.bio,
        "pfp": profile.pfp
      }))
      .timeout(const Duration(seconds: 5));
      if (response.statusCode != 201) {
        // not ok
        throw Exception(response.reasonPhrase);
      }
      Map<String, dynamic> converted = decoder.convert(response.body);

    return converted;
  }
}