import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _loginState();
}

class _loginState extends State<register> {
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
                  "Account register",
                  style: TextStyle(
                    fontSize: 40),)
                ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.amber
                    )
                    ),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: const TextField(
                  style: TextStyle(fontSize: 20),
                  maxLines: 1,
                  decoration: InputDecoration.collapsed(
                    hintText: "password", ),
                  obscureText: true, 
                  obscuringCharacter: "*")),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: MaterialButton(
                        onPressed: (){
                          
                        },    // TODO: implement this register function
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
}