import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:orbital/message.dart';
import 'package:orbital/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class myChat extends StatefulWidget {
  const myChat({super.key});

  @override
  State<myChat> createState() => _ChatState();
}

class _ChatState extends State<myChat> {
  List<Message>? messages = [];
  
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    Profile oppProfile = arguments['oppProfile'];
    String? msg;  
    ScrollController controller = ScrollController();
    TextEditingController textControl = TextEditingController();

    Timer.periodic(Duration(seconds: 3), (time) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      JsonDecoder decoder = const JsonDecoder();

      final response = await http.post(Uri.parse('http://13.231.75.235:8080/getMessage'),
      body: jsonEncode({
        "id_from": prefs.getString('id'),
        "id_to": oppProfile.id,
        "time_sent": "${DateTime.now().toIso8601String()}Z",
      }))
      .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(response.reasonPhrase);
      }

      var converted = decoder.convert(response.body);
      if (converted['body'][0] != null && messages != null) {
        if (converted['body'][0][0]['msg_id'] > int.parse(messages![0].msg_id) && converted['body'][0][0]['msg_id'] - int.parse(messages![0].msg_id) < 10) {
          int calculated = (10 - (converted['body'][0][0]['msg_id'] - int.parse(messages![0].msg_id)) - 1).toInt();
          var cutted = messages!.sublist(calculated);
          
          List<Message> messagesLoop = [];
          for (var element in converted['body'][0]) {
            var temp = Message(element['id_from'].toString(), element['id_to'].toString(), element['msg'], DateTime.parse(element['time_sent']), element['msg_id'].toString());
            messagesLoop.add(temp);     
          }

          messages = messagesLoop + cutted;

          setState(() {
            messages;
          });
        }
       }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back,color: Colors.black,),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Image.network(
                    oppProfile.pfp,
                    height: 50,
                    width: 50,
                    ),
                ),
                Text(oppProfile.name)
              ]
              )
            )
          )
        ),
        body: Stack(
        children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: FutureBuilder(
                future: getMessages(oppProfile), 
                builder: (context, snapshot) {
                  
                  if (snapshot.hasData && messages!.length == 0){
                    messages = snapshot.data;
                  }             
                  int len = 0;
                  if (messages != null) {
                    len = messages!.length;
                  }
                  return ListView.builder(
                    itemCount: len,
                    controller: controller,
                    reverse: true,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    itemBuilder: (context, index){
                      return Container(
                        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                        child: Align(
                          alignment: (messages![index].id_from == oppProfile.id ?Alignment.topLeft:Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (messages![index].id_from == oppProfile.id?Colors.grey.shade200:Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(messages![index].msg, style: TextStyle(fontSize: 15),),
                          ),
                        ),
                      );
                    },
                  );
                }
                        ),
            ), 
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: textControl,
                      onChanged: (value) {msg = value;},
                      decoration: const InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: () async {
                      if (msg != null) {
                        var res = await sendMessage(oppProfile, msg!);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        messages!.insert(0, res);
                        textControl.clear();
                        setState(() {
                          messages;
                        });  
                        controller.animateTo(
                          0.0,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                      }                   
                    },
                    child: Icon(Icons.send,color: Colors.white,size: 18,),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
                
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<Message>?> getMessages(Profile oppProfile) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  final response = await http.post(
    Uri.parse('http://13.231.75.235:8080/getMessage'), 
    body: jsonEncode(
      <String, String>{
        "id_from": prefs.getString("id")!,
        "id_to" : oppProfile.id,
        "time_sent" : "${DateTime.now().toIso8601String()}Z"
        })).timeout(const Duration(seconds: 5));

  JsonDecoder decoder = const JsonDecoder();
  List<Message> messages = List.empty(growable: true);

    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);

      if (converted['body'][0] != null) {
          for (var element in converted['body'][0]) {
            var temp = Message(element['id_from'].toString(), element['id_to'].toString(), element['msg'], DateTime.parse(element['time_sent']), element['msg_id'].toString());
            messages.add(temp);     
          }
        return messages;
      }
    }
    return null;
}

Future<Message> sendMessage(Profile oppProfile, String msg) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.post(
    Uri.parse('http://13.231.75.235:8080/sendMessage'), 
    body: jsonEncode(
      <String, String>{
        "id_from": prefs.getString("id")!,
        "id_to" : oppProfile.id,
        "msg" : msg
        })).timeout(const Duration(seconds: 5));

  JsonDecoder decoder = const JsonDecoder();
  if (response.statusCode == 200) {
    var converted = decoder.convert(response.body);
    
    if (converted['err_msg'] != "ok") {
      throw Exception(converted['err_msg']);
    }

    var ret = Message(converted['body'][0]['id_from'].toString(), converted['body'][0]['id_to'].toString(), converted['body'][0]['msg'], DateTime.parse(converted['body'][0]['time_sent']), converted['body'][0]['msg_id'].toString());

    return ret;
  } 

  throw Exception(response.reasonPhrase);
}