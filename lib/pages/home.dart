import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.amber,
                    padding: EdgeInsets.all(5),
                    child: Text('back'),
                    onPressed: (){ }
                    ),
                ),
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      child: Center(child: Text('title')),
                      ),
                  ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.amber,
                    padding: EdgeInsets.all(5),
                    child: Text('options'),
                    onPressed: (){ }
                    ),
                ),
              ],
            ),//navigation
          ],
        ),
      ),
    );
  }
}