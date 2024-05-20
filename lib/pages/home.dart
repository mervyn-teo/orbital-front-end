
import 'package:flutter/material.dart';
import 'package:orbital/Profile.dart';
import 'package:orbital/pages/other_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_bubbles/chat_bubbles.dart';

Profile myProf = Profile('zhang haodong', 'dassdas', 2121, 'i love trains', 'assets/default_profile.png');

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int? metPpl = 123456; // TODO: use API to grab this

  // this determines which page is loaded
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
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
              icon: Icon(Icons.settings), 
              label: 'Settings'),
            NavigationDestination(
              icon: Icon(Icons.chat), 
              label: 'Chats'),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined), 
              label: 'Profile')
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
            } // TODO: this cant handle situation gracefully when server is down
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
            return settingPage();
          case 2:
            return chatList();
          case 3:
            return myProfile();
          default:
            return await matchedPage();
        }
  }

  //generate page for my profile
  Widget myProfile() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Card(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 70,
              child: Image(
                image: AssetImage(myProf.pfp)
              )
            )
          )
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 26, 0, 0),
          child: MaterialButton(
            color: Colors.amber,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () => {},
            child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 20),)),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 26, 0, 0),
          child: Text(myProf.name, style: const TextStyle(fontSize: 24),)),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Text(myProf.age.toString(), style: const TextStyle(fontSize: 18),)),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Text(myProf.bio, style: const TextStyle(fontSize: 12),)),
      ],
    );
  }

  // requests and sanitise data through API
  Future<List<Profile>> requestProfiles() async{
    JsonDecoder decoder = const JsonDecoder();
    List<Profile> ret = List.empty(growable: true);

    final response = await http.get(Uri.parse('http://13.231.75.235:8080/profiles')).timeout(const Duration(seconds: 5));
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      // check for ok in err_msg
      if (converted['err_msg'] != "ok") {
        throw Exception(converted['err_msg']);
      } else {
        for (var element in converted['body'][0]) {
          ret.add(Profile(element['name'], element['id'], element['age'], element['bio'], element['pfp']));     
        }
        return ret;
      }
    } else {
      throw Exception('Failed to load');
    }
  } 

  // generate page for matched people
  Future<Widget> matchedPage() async {
    List<Card> cards = await getCards();
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: Text('you have passed by $metPpl people',
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
    List<Profile>? matchedProfiles = await requestProfiles(); 
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
      child: InkWell(
        onTap: ()=> {
          Navigator.push(context, 
            MaterialPageRoute(builder: (context) => otherProfile(profile: profile)))}, // goes to the profile page
               child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: Image(image: NetworkImage(profile.pfp), 
                    width: 70,
                    height: 70,
                    ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,),
                Text(profile.age.toString(),),
                Text(profile.bio.length > 30 ? '${profile.bio.substring(0, 30)}...' : profile.bio),
              ],
            )
          ],
        ),
      ),
      );
  }

  Future<Widget> chatList() async {
    List<Card> cards = await getCards(); // TODO: make cards specific for chattable, now using profile directly
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
              children: cards,
              ),
            ),
      ),
      ]
    );
  }

  // TODO: implement logic for this
  Widget myChat() {
    return Column(
      children: <Widget>[
        myChatBubble('hello, its me'),
        otherChatBubble('i see its me'),
      ],
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


  // TODO: this is not very elegant, change this soon
  // the default values of settings
  // MUST BE GLOBAL unless better solution is found
  bool settingsBoolean1 = false;
  bool settingsBoolean2 = true;

  Widget settingPage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('description 1'),
              Switch(
                value: settingsBoolean1, 
                onChanged: (bool val){
                  setState(() {
                    settingsBoolean1 = val;
                  });
                }
                )
              ],
                ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('description 2'),
              Switch(
                value: settingsBoolean2, 
                onChanged: (bool val){
                  setState(() {
                    settingsBoolean2 = val;
                  });
                }
                )
              ],
                ),
        ),
         ],
      ),
    );
  }





}

