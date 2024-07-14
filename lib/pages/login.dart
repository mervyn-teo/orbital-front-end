import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orbital/pages/register.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:auth_buttons/auth_buttons.dart';

var loginEmailKey = const Key('login_email');
var loginPwdKey = const Key('login_password');

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  String? email;
  String? password;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Column(children: [
            const SizedBox(height: 150),
            Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 10, 0),
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
                  key: loginEmailKey,
                  style: const TextStyle(fontSize: 20),
                  enableSuggestions: true,
                  maxLines: 1,
                  onChanged: (value) {email = value;},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "E-mail", ),
                  keyboardType: TextInputType.emailAddress,)),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  key: loginPwdKey,
                    style: const TextStyle(fontSize: 20),
                    maxLines: 1,
                    onChanged: (value) {password = value;},
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password", ),
                    obscureText: true,
                    obscuringCharacter: "*")
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(25, 0, 30, 10),
              child: RichText(
                text: TextSpan(
                  children: [
                     const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: "Sign up here",
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const register()),
                          );
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            MaterialButton(
                key: const Key('login_button'),
                onPressed: () {
                  login();
                },    // TODO: implement info handling after API response
                color: Colors.amber,
                child: const Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black),
                )
            ),
            // SizedBox(height: 20),
            // const Row(
            //   children: <Widget>[
            //     Expanded(
            //       child: Divider()
            //     ),
            //     Text("   OR continue with  "),
            //     Expanded(
            //       child: Divider()
            //     ),
            //   ]
            // ),
            // const SizedBox(height: 20),
            // GoogleAuthButton(
            //   onPressed: () {
            //     // your implementation
            //     setState(() {
            //     });
            //   },
            //   style: const AuthButtonStyle(
            //     margin: EdgeInsets.only(bottom: 20),
            //   ),
            // ),
            // FacebookAuthButton(
            //   onPressed: () {
            //     // your implementation
            //     setState(() {
            //     });
            //   },
            //   style: const AuthButtonStyle(
            //     margin: EdgeInsets.only(bottom: 20),
            //   ),
            // ),
          ],
          ),
        ),
      ),
    );
  }

  void login() async {
    if (email == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              key: Key("empty_email_popup"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(20)
                  )
              ),
              title: Text("e-mail cannot be empty!"),
              content: Text("please make sure your email is correct!"),
            );
          }
      );
    } else if (password == null){
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              key: Key("empty_password_popup"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(20)
                  )
              ),
              title: Text("password cannot be empty!"),
              content: Text("please make sure your password is correct!"),
            );
          }
      );
    } else if (!EmailValidator.validate(email!)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              key: const Key("error_email_popup"),
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
      String errMsg = await loginResponse(email!, password!).catchError((e) {
        return e.toString();
      });
      if (errMsg != "ok") {
        showDialog(
            context: context,
            builder: (context) {
              return  AlertDialog(
                key: const Key('error_login_failed'),
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
        Navigator.pushNamedAndRemoveUntil(context, '/home',(Route<dynamic> route) => false);
      }
    }
  }

}
  Future<String> loginResponse(String email, String pwd, {http.Client? client}) async {
    JsonDecoder decoder = const JsonDecoder();
    client ??= http.Client();

    try {
      final response = await client.post(Uri.parse('http://13.231.75.235:8080/login'),
          body: jsonEncode(<String, String>{
            "email": email,
            "pwd": pwd
          }))
          .timeout(const Duration(seconds: 5));

      var converted = decoder.convert(response.body);

      // check if resonse is not ok
      if (converted['err_msg'] == "ok") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', converted['body'][0]['name']);
        await prefs.setString('bio', converted['body'][0]['bio']);
        await prefs.setInt('age', converted['body'][0]['age']);
        await prefs.setString('id', converted['body'][0]['id']);
        await prefs.setString('pfp', converted['body'][0]['pfp']);
        await prefs.setBool('hasLoggedIn', true);
      }

      return converted['err_msg'];
    } on Exception catch(e) {
      return e.toString();
    }
  }