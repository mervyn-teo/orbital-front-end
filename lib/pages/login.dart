import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orbital/pages/register.dart';

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
                child: const TextField(
                  style: TextStyle(fontSize: 20),
                  enableSuggestions: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "e-mail", ),
                  keyboardType: TextInputType.emailAddress,)),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: const TextField(
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                  decoration: InputDecoration(
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
                        onPressed: (){},    // TODO: implement this login function
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

  void login() {
    
  }
}