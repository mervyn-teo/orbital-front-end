import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:orbital/Profile.dart';
import 'package:orbital/event.dart';
import 'package:orbital/pages/other_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart'as calender;

Profile myProf = Profile('Zhang Haodong', 'dassdas', 2121, 'i love trains', 'assets/default_profile.png');

class homePage extends StatefulWidget {
  const homePage({super.key});
  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final TextEditingController _tagPopUpController = TextEditingController();
  final TextEditingController _eventNamePopUpController = TextEditingController();
  final TextEditingController _eventDesPopUpController = TextEditingController();
  final TextEditingController _eventSizePopUpController = TextEditingController();
  DateTime dateTime = DateTime.now();

  
  // this determines which page is loaded
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key("home_page"),
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          elevation: 2,
          selectedIndex: pageIndex,
          height: 67,
          onDestinationSelected: (value) => setState(() {
            pageIndex = value;
          }),
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_outlined), 
              label: 'Matched'),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), 
              label: 'Events'),
            NavigationDestination(
              icon: Icon(Icons.chat), 
              label: 'Chats'),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined), 
              label: 'Profile'),
            NavigationDestination(
              icon: Icon(Icons.settings), 
              label: 'Settings')
        ]),
        body: FutureBuilder<Widget>(
          future: choosePage(pageIndex),
          initialData: const Text('Loading louder...'),
          builder: (context, snapshot) {
            Widget children;
            if (snapshot.hasData) {
              children = snapshot.data!;
            } else if (snapshot.hasError) {
              children = Text(snapshot.error.toString());
            } else {
              children = const Text('Loading...');
            } 
            return children;
          },),
      ),
        );
  }

  Future<Widget> choosePage(pageIndex) async{
    switch (pageIndex) {
          case 0:
            return await matchedPage();
          case 1:
            return await eventList();
          case 2:
            return await chatList();
          case 3:
            return await myProfile();
          case 4:
            return await settingPage();
          default:
            return await matchedPage();
        }
  }

  Future<Widget> eventList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
 
    return SafeArea(  
      child: Scaffold(
        body: await events(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {_displayEventInputDialog(context);},
          shape: CircleBorder(),
          child: Icon(Icons.add),),
        )
        );
  }

  // generate page for events
  Future<Widget> events() async {
    List<Card>? cards = await getEventCards(); 

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: const Text('Events',
            style: TextStyle(fontSize: 45),
            ),
        ),
        SizedBox(
          height: 618,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
              });
            },
            child: ListView(
              children: cards ?? List.of([Container()]),
              ),
            ),
      ),
      ]
    );
  }

  Future<List<Card>> getEventCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Event> events = await getEvents();
    List<Card> cards = List.empty(growable: true);

    for (var element in events) {
      if (element.userId.length > 0) {
        if (element.userId.contains(int.parse(prefs.getString('id')!))) {
          cards.add(Card(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            color: Colors.amberAccent,
            elevation: 4,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Add this event to your calender?"),
                      actions: [
                        MaterialButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                          ),
                        MaterialButton(
                          child: const Text("OK"),
                          onPressed: () {
                            calender.Event event = calender.Event(
                              title: element.name,
                              description: element.description,
                              startDate: element.dateTime,
                              endDate: element.dateTime.add(const Duration(days: 1)),
                            );
                            calender.Add2Calendar.addEvent2Cal(event);
                            Navigator.pop(context);
                          }
                          )
                      ],
                    );
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    if (element.owner != prefs.getString("id")) ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                        child:  const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Participated',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.black54,
                            ),),
                        ),
                      ),
                    ] else ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                        child:  const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Owner',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.black54,
                            ),),
                        ),
                      ),
                    ],
                    Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Event Name: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.name}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Event Description: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.description}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Date and time: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.dateTime}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Numbers of participents: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "${element.userId.length}/${element.size}",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  if (element.owner != prefs.getString("id")) ... [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          elevation: 2,
                          color: Colors.greenAccent,
                          child: Text("Withdraw"),
                          onPressed: () {
                            quitEvent(element.eventId);
                            setState(() {
                            });
                          }
                          ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          elevation: 2,
                          color: Colors.greenAccent,
                          child: Text("Remove"),
                          onPressed: () {
                            removeEvent(element.eventId);
                            setState(() {
                            });
                          }
                          ),
                      ),
                    ),
                  ]
                  ],
                ),
              ),
            )
          ));
        } else {
          cards.add(Card(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        color: Colors.amberAccent,
        elevation: 4,
        child: InkWell(
          onTap: () {
                showDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Add this event to your calender?"),
                      actions: [
                        MaterialButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                          ),
                        MaterialButton(
                          child: const Text("OK"),
                          onPressed: () {
                            calender.Event event = calender.Event(
                              title: element.name,
                              description: element.description,
                              startDate: element.dateTime,
                              endDate: element.dateTime.add(const Duration(days: 1)),
                            );
                            calender.Add2Calendar.addEvent2Cal(event);
                            Navigator.pop(context);
                          }
                          )
                      ],
                    );
                });
              },
          child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Event Name: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.name}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Event Description: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.description}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Date and time: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "\n${element.dateTime}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text.rich(
                      TextSpan(
                        text: "Numbers of participents: ",
                        style: const TextStyle(
                          fontSize: 20
                        ), children: <InlineSpan>[
                          TextSpan(
                            text: "${element.userId.length}/${element.size}",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 114, 172)
                            )
                          )
                        ])),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        elevation: 2,
                        color: Colors.greenAccent,
                        child: Text("join"),
                        onPressed: () {
                          joinEvent(element.eventId);
                          setState(() {
                          });
                        }
                        ),
                    ),
                  )
                ],
              ),
            ),
        )
        ));
        }
      }
    }

    return cards;
  }
 
  Future<bool> isReported(id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/checkReported'), 
    body: jsonEncode(
      {
        "id_from" : prefs.getString('id')!,
        "id_to" : id
      }
    )).timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
        return converted['body'][0];
      }
    } else {
      throw Exception('Failed to load');
    }
  }

    Future<void> removeEvent(eventId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();

    final response = await http.delete(Uri.parse('http://13.231.75.235:8080/removeEvent'), 
    body: jsonEncode(
      {
        "id" : eventId
      }
    )).timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
        return converted['body'][0];
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<Event>> getEvents() async {
    JsonDecoder decoder = const JsonDecoder();
    List<Event> ret = List.empty(growable: true);

    final response = await http.get(Uri.parse('http://13.231.75.235:8080/getEvent'))
      .timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
      if (converted['body'][0] != null) {
        for (var element in converted['body'][0]) {
            List<int> userIdList = List<int>.from(element['user_id']);
            var temp = Event(userIdList, element['event_id'], element['name'], element['description'], DateTime.parse(element['date_time']), element['size'], element['owner']);
            ret.add(temp);
          }
        }                  
        
        return ret;
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> _displayEventInputDialog(BuildContext context) async {{}
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new Event'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) { 
              return Column(
              children: [
                TextField(
                  controller: _eventNamePopUpController,
                  decoration: const InputDecoration(
                    hintText: "e.g. fishing", 
                    labelText: "Event Name"),
                ),
                TextField(
                  controller: _eventDesPopUpController,
                  decoration: const InputDecoration(
                    hintText: "e.g. the quick brown fox jumps over the lazy dog",
                    labelText: "Event description"),
                ),
                TextField(
                  controller: _eventSizePopUpController,
                  decoration: const InputDecoration(
                    hintText: "e.g. 15",
                    labelText: "Size"),
                  keyboardType: TextInputType.number,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.left,
                      "Date & time selected: \n${DateFormat('yyyy-MM-dd   kk:mm').format(dateTime)}",
                      style: const TextStyle(
                        fontSize: 20),),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    color: Colors.amberAccent,
                    elevation: 2,
                    child: const Text("choose a date"),
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime.now().add(const Duration(days: 3650)), 
                        onConfirm: (date) {
                          setState(() {
                            dateTime = date;
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                  ),
                )
              ],
            );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: const Text('OK'),
              onPressed: () async {
                // check if empty
                if (_eventSizePopUpController.text == "" || _eventNamePopUpController.text == "" || _eventDesPopUpController.text == "") {
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return const AlertDialog(
                        title: Text(
                          "Fill in all the blanks!",
                          style: TextStyle(
                            fontSize: 15,
                          ),),
                      );
                    });
                } else {
                  await createEvent(_eventNamePopUpController.text, _eventDesPopUpController.text, dateTime, int.parse(_eventSizePopUpController.text));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createEvent(String name, String description, DateTime datetime, int size) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/setEvent'), 
      body: jsonEncode({
        "user_id": [int.parse(prefs.getString("id")!)],
        "size" : size,
        "name" : name,
        "description" : description,
        "date_time" : "${datetime.toIso8601String()}Z",}))
      .timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
       throw Exception('Failed to load');
      }
    }
  }

  Future<void> joinEvent(String eventId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/addIdToEvent'), 
      body: jsonEncode({
        "id" : int.parse(prefs.getString("id")!),
        "event_id" : eventId
      }))
      .timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
       throw Exception('Failed to load');
      }
    }
  }

    Future<void> quitEvent(String eventId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();

    print("${eventId.runtimeType}, ${prefs.getString("id")!.runtimeType}");
    final response = await http.post(Uri.parse('http://13.231.75.235:8080/removeIdFromEvent'), 
      body: jsonEncode({
        "user_id" : prefs.getString("id")!,
        "event_id" : eventId
      }))
      .timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
       throw Exception('Failed to load');
      }
    }
  }

  //generate page for my profile
  Future<Widget> myProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Center> tags = await requestTags(prefs.getString('id')!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(20, 40, 0, 0),
          child: Card(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(prefs.getString('pfp')!)
            )
          )
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 26, 0, 0),
          child: Text("Name: \n${prefs.getString('name')!}", style: const TextStyle(fontSize: 24),)),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 0, 0),
          child: Text("Age: \n${prefs.getInt('age').toString()}", style: const TextStyle(fontSize: 18),)),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 0, 0),
          child: Text("Bio: \n${prefs.getString('bio')!}", style: const TextStyle(fontSize: 18),)),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(20, 26, 0, 0),
          child: MaterialButton(
            color: Colors.amber,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onPressed: () {
              Navigator.popAndPushNamed(context, "/profilesetting", arguments: {"id" : prefs.getString('id'), "isFirstTime": false});
            },
            child: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontSize: 20),)),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 0, 0),
          child: const Text('Tags', style: TextStyle(fontSize: 24),)),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: SizedBox(
            height: 50,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                scrollDirection: Axis.horizontal,
                children: tags,
              ),
            )
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 0, 0),
          child: MaterialButton(
            color: Colors.greenAccent,
            onPressed: () {
              prefs.setBool('hasLoggedIn', false);
              Navigator.popAndPushNamed(context, '/login');
            },
            child: const Text('log out'),
          ),
        )
      ],
    );
  }

  // requests and sanitise data through API
  Future<List<Profile>?> requestProfiles() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonDecoder decoder = const JsonDecoder();
    List<Profile> ret = List.empty(growable: true);

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/matches'), body: jsonEncode(<String, String>{"id": prefs.getString("id")!})).timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
      if (converted['body'][0] != null) {
        for (var element in converted['body'][0]) {
            ret.add(Profile(element['name'], element['id'], element['age'], element['bio'], element['pfp']));     
          }
        }                  
        
        return ret;
      }
    } else {
      throw Exception('Failed to load');
    }
  } 

    // requests and sanitise data through API
  Future<List<Center>> requestTags(String id) async{
    JsonDecoder decoder = const JsonDecoder();
    List<Center> ret = List.empty(growable: true);

    final response = await http.post(Uri.parse('http://13.231.75.235:8080/tags',), body: jsonEncode(<String, String>{"id": id})).timeout(const Duration(seconds: 5),);
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
        if (converted['body'][0].length < 6) {
          ret.add(Center(
            child: InkWell(
              onTap: () {
                _displayTextInputDialog(context);
              },
              child: InkWell(
                onTap: () {
                  _displayTextInputDialog(context);
                  },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  elevation: 4,
                  color: Colors.amber,
                  child: const SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        "+",
                      ),
                    ))),
              ),
            )));
        }
        for (var element in converted['body'][0]) {
          ret.add(Center(
            child: InkWell(
              onTap: () {
                removeTagDialog(context, element['tag']);
              },
              child: Card(
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
            ),
          ));     
        }
        return ret;
      }
    } else {
      throw Exception('Failed to load');
    }
  } 

Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new tag'),
          content: TextField(
            controller: _tagPopUpController,
            decoration: const InputDecoration(hintText: "e.g. fishing"),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: const Text('OK'),
              onPressed: () {
                addTag(_tagPopUpController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  

  Future<void> removeTagDialog(BuildContext context, String tag) {
        return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove a new tag'),
          content: const Text('Are you sure you want to remove this tag?'),
          actions: <Widget>[
            MaterialButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: const Text('OK'),
              onPressed: () {
                removeTag(tag);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeTag(String tag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.delete(Uri.parse('http://13.231.75.235:8080/tags',), body: jsonEncode(<String, String>{"id": prefs.getString("id")!, "tag": tag})).timeout(const Duration(seconds: 5),);
    JsonDecoder decoder = const JsonDecoder();

    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        showDialog(
          context: context, 
          builder: (context) {
            return  AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: const Text("Unable to remove tags!"),
                content: Text(converted['err_msg']),
            );
          }
        );
      } else {
        setState(() {
        });
      }
    }
    
  }

  Future<void> addTag(String tag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.put(Uri.parse('http://13.231.75.235:8080/tags',), body: jsonEncode(<String, String>{"id": prefs.getString("id")!, "tag": tag})).timeout(const Duration(seconds: 5),);

    JsonDecoder decoder = const JsonDecoder();
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        showDialog(
          context: context, 
          builder: (context) {
            return  AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20)
                )
                ),
                title: const Text("Unable to add tags!"),
                content: Text(converted['err_msg']),
            );
          }
        );
      } else {
        setState(() {
        });
      }
    }
  }

  Future<int> getMetPpl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse('http://13.231.75.235:8080/metNumber',), body: jsonEncode(<String, String>{"id": prefs.getString("id")!})).timeout(const Duration(seconds: 5),);

    JsonDecoder decoder = const JsonDecoder();
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
      } else {
        return converted['body'][0];
      }
    } 
    print('how am i here');
    return 0;
  }

  // generate page for matched people
  Future<Widget> matchedPage() async {
    int metPpl = await getMetPpl();
    List<Card> cards = await getCards();
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: Text('you have passed other users $metPpl times',
            style: const TextStyle(fontSize: 12))),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: const Text('Matched: ',
            style: TextStyle(fontSize: 24))),
          SizedBox(
            height: 550,
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                });
              },
              child: ListView(
                children: cards,
              )
            )
          )
        ]
    );
  }

  // generate cards from list of profiles
  Future<List<Card>> getCards() async{
    List<Profile>? matchedProfiles = await requestProfiles() ?? [myProf]; 
    List<Card> ret = List.empty(growable: true);
    for (var profile in matchedProfiles) {
      ret.add(makeProfileCards(profile));
    }
    return ret;
    } 

  // template for profile cards
  Card makeProfileCards(Profile profile) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(15, 16, 15, 0), 
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: InkWell(
          onTap: ()=> {
            Navigator.push(context, 
              MaterialPageRoute(builder: (context) => otherProfile(profile: profile, )))}, // goes to the profile page
                 child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(35),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(profile.pfp), 
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name,),
                          Text(profile.age.toString(),),
                          Text(profile.bio.length > 30 ? '${profile.bio.substring(0, 30)}...' : profile.bio),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 60, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (await addInterest(profile.id)){
                                      setState(() {
                                    });
                                    }
                                  }, 
                                  icon: const Icon(Icons.check)
                                  ),
                                IconButton(
                                  onPressed: () async {
                                    if (await addNotInterest(profile.id)){
                                      setState(() {
                                    });
                                    }
                                  }, 
                                  icon: const Icon(Icons.close),
                                  )
                                ],
                            ),
                          ),                       
                        ],
                      ),
                    ),
                  ],
          ),
        ),
      ),
      );
  }

  Future<bool> addInterest(String idTo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse('http://13.231.75.235:8080/addInterest',), body: jsonEncode(<String, String>{"id_from": prefs.getString("id")!, "id_to": idTo})).timeout(const Duration(seconds: 5),);

    JsonDecoder decoder = const JsonDecoder();
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
    return converted['err_msg'] == "ok";
    }
    return false;
  }

    Future<bool> addNotInterest(String idTo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse('http://13.231.75.235:8080/addNotInterest',), body: jsonEncode(<String, String>{"id_from": prefs.getString("id")!, "id_to": idTo})).timeout(const Duration(seconds: 5),);

    JsonDecoder decoder = const JsonDecoder();
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
    return converted['err_msg'] == "ok";
    }
    return false;
  }

  Future<Card> makeChatCard(Profile msgObj) async {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      color: Colors.amber,
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/chat', arguments: {'oppProfile' : msgObj});
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Image.network(
                  msgObj.pfp,
                  height: 80,
                  width: 80,
                  )),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(msgObj.name))
            ],
          ),
        )
      ),
    );
  }

  // Chat

  Future<List<Card>?> getChatable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString("id"));


    final response = await http.post(Uri.parse('http://13.231.75.235:8080/getChat',), body: jsonEncode(<String, String>{"id": prefs.getString("id")!})).timeout(const Duration(seconds: 5),);
    JsonDecoder decoder = const JsonDecoder();
    List<Card> cards = List.empty(growable: true);

    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);

      if (converted['body'][0] != null) {
          for (var element in converted['body'][0]) {
            var temp = Profile(element['name'], element['id'], element['age'], element['bio'], element['pfp']);
            if (!await isReported(temp.id)) {
              cards.add(await makeChatCard(temp));     
            }
          }
        return cards;
      }
    }
    return null;
  }

  Future<Widget> chatList() async {
    List<Card>? cards = await getChatable(); // TODO: make cards specific for chattable, now using profile directly

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: const Text('Chat',
            style: TextStyle(fontSize: 45),
            ),
        ),
        SizedBox(
          height: 618,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
              });
            },
            child: ListView(
              children: cards ?? List.of([Container()]),
              ),
            ),
      ),
      ]
    );
  }

  Widget myChatBubble(String text) {
    return BubbleNormal(
      color: Colors.grey.shade300,
      isSender: true,
      tail: true,
      text: text
    );
  }

  Widget otherChatBubble(String text) {
    return BubbleNormal(
      color: Colors.blue.shade300,
      textStyle: const TextStyle(color: Colors.white),
      isSender: false,
      tail: true,
      text: text
    );
  }

  // Settings
  Future<Widget> settingPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Allow the app to log your GPS activities'),
              Switch(
                value: prefs.getBool('GPSLogging')!, 
                onChanged: (bool val) async {
                    await prefs.setBool('GPSLogging', val);
                    setState(() {
                    });
                }
                )
              ],
                ),
        ),
        // Container(
        //   margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const Text('placeholder 2'),
        //       Switch(
        //         value: settingsBoolean2, 
        //         onChanged: (bool val){
        //           setState(() {
        //             settingsBoolean2 = val;
        //           });
        //         }
        //         )
        //       ],
        //         ),
        // ),
         ],
      ),
    );
  }





}

