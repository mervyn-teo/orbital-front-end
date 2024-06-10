import 'package:flutter/material.dart';
import 'package:orbital/Profile.dart';
import 'package:orbital/pages/home.dart';
import 'package:orbital/tag.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
              Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: const Text('Tags', style: TextStyle(fontSize: 24),)),  
              FutureBuilder(future: requestTags(profile.id), builder: (context, snapshot) {
                var ret = snapshot.data ?? List.empty();
                
                return  SizedBox(
                  height: 80,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      scrollDirection: Axis.horizontal,
                      children: ret,
                    ),
                  )
                );
              })
            ],
          ),
      ) 
    );
  }

      // requests and sanitise data through API
  Future<List<Card>> requestTags(String id) async{
    JsonDecoder decoder = const JsonDecoder();
    List<Card> ret = List.empty(growable: true);

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/tags',), body: jsonEncode(<String, String>{"id": id})).timeout(const Duration(seconds: 5),);
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
        for (var element in converted['body'][0]) {
          ret.add(
             Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              elevation: 4,
              color: Colors.amber,
              child: SizedBox(
                width: 60,
                child: Center(
                  child: Text(
                    element['tag'],
                  ),
                )),
              ),
          );     
        }
        return ret;
      }
    } else {
      throw Exception('Failed to load');
    }
  } 
}