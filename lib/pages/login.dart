import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orbital/pages/register.dart';
import 'package:email_validator/email_validator.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  late String email;
  late String password;

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
                  "Account Login",
                  style: TextStyle(
                    fontSize: 40),)
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  onChanged: (value) {password = value;},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "password", ),
                  obscureText: true, 
                  obscuringCharacter: "*")),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: RichText(
                          text: TextSpan(
                            text: "don't have an account? sign up here",
                            style: TextStyle(color: Colors.grey),
                            recognizer: TapGestureRecognizer() ..onTap = () {                        
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const register()));
                              }
                            ),
                          textAlign: TextAlign.left,
                        ),
                    ),
                    MaterialButton(
                        onPressed: (){
                          login();
                        },    // TODO: implement info handling after API response
                        color: Colors.amber,
                        child: const Text(
                          "Login", 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,),
                      )
                      ),
                    ]),
              ),
                ],
              ),
        ),
      );
  }

  Future<bool> login() async {
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
    } else {
      String errMsg = await loginResponse(email, password).catchError((e) {
        return "Server response timeout!";
      });
      if (errMsg != "ok") {
        showDialog(
          context: context, 
          builder: (context) {
            return  AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: const Text("login failed"),
                content: Text(errMsg),
            );
          }
        );
      } else {
        showDialog(
          context: context, 
          builder: (context) {
            return  const AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: Text("Login Success!"),
                content: Text("you have sucessfully logged in"),
            );
          }
        );
        return true;
      }
    }
    return false;
  }

  Future<String> loginResponse(String email, String pwd) async {
    JsonDecoder decoder = JsonDecoder();
    String retStatus = "";

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/login'),
      body: jsonEncode(<String, String>{
        "email": email,
        "pwd": pwd
      }))
      .timeout(const Duration(seconds: 5));
      
      var converted = decoder.convert(response.body);

    return converted['err_msg'];  
  }
}