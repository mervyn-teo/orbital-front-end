import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbital/pages/register.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
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
                padding: EdgeInsets.fromLTRB(20, 50, 10, 50),
                alignment: Alignment.center,
                child: const Text(
                  "Account Login",
                  style: TextStyle(
                    fontSize: 40),)
                ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.amber
                    )
                    ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0) ,
                child: const TextField(
                  style: TextStyle(fontSize: 20),
                  enableSuggestions: true,
                  maxLines: 1,
                  decoration: InputDecoration.collapsed(
                    hintText: "email",),
                  keyboardType: TextInputType.emailAddress,)),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: const TextField(
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                  decoration: InputDecoration.collapsed(
                    hintText: "password", ),
                  obscureText: true, 
                  obscuringCharacter: "*")),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const register()));
                      },
                      color: null,
                      child: const Text(
                        "don't have an account? sign up here",
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
}