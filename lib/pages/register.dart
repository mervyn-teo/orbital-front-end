import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _loginState();
}

class _loginState extends State<register> {
String email = "";
String pwd = "";

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => {Navigator.pop(context)}),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 10, 50),
                alignment: Alignment.center,
                child: const Text(
                  "Account register",
                  style: TextStyle(
                    fontSize: 40),)
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0) ,
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  enableSuggestions: true,
                  maxLines: 1,
                  onChanged: (value) {email = value;},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "e-mail", ),
                  keyboardType: TextInputType.emailAddress,)),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  onChanged: (value) {pwd = value;},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "password", ),
                  obscureText: true, 
                  obscuringCharacter: "*")),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: MaterialButton(
                        onPressed: () async {
                          register();
                        },
                        color: Colors.amber,
                        child: const Text(
                          "Register", 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,),
                      )
                      ),
                    ),
              ]),
              )
              );
  }


  Future<bool> register() async {
    // TODO: (maybe) add email validation by sending email with comfirmation code
    
    // validate email content
    if (!EmailValidator.validate(email)) {
      showDialog(
        context: context, 
        builder: (context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20)
              )
              ),
              title: Text("invalid e-mail!"),
              content: Text("please make sure your email is correct!"),
          );
      }
      );
    } else if (pwd.length < 5) {
        showDialog(
        context: context, 
        builder: (context) {
          return const AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20)
              )
              ),
              title: Text("invalid password!"),
              content: Text("please make sure your password is longer than 5 characters!"),
          );
      }
      );
    } else{
      var responses = await registerSuccess(email, pwd).catchError((e) {
        return "Server response timeout!";
      });
      if (responses['err_msg'] != "ok") {
        showDialog(
          context: context, 
          builder: (context) {
            return  AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: const Text("Registration failed"),
                content: Text(responses['err_msg']),
            );
          }
        );
      } else {
          //success
          Navigator.popAndPushNamed(context, "/profilesetting", arguments: {"id" : responses['body'][1].toString()});
        return true;
      }
    }
    return false;
  }
  

  Future<dynamic> registerSuccess(String email, String pwd,) async {
    JsonDecoder decoder = const JsonDecoder();
    String retStatus = "";

    try {
    final response = await http.post(Uri.parse('http://13.231.75.235:8080/register'),
      body: jsonEncode(<String, String>{
        "email": email,
        "pwd": pwd
      }))
      .timeout(const Duration(seconds: 5));

      final Map<String, dynamic> converted = decoder.convert(response.body);

      return converted;
    } on Exception catch (e) {
      showDialog(
          context: context, 
          builder: (context) {
            return  AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: const Text("Registration failed"),
                content: Text(e.toString()),
            );
          }
        );
    }

  }
}