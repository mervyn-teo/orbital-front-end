import 'package:flutter/material.dart';
import 'package:orbital/Profile.dart';
import 'package:orbital/pages/other_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Profile myProf = Profile('zhang haodong', 'dassdas', 2121, 'i love trains', 'assets/default_profile.png');

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int? metPpl = 123456; // TODO: use API to grab this
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
            return Container();
          case 2:
            return Container();
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

    final response = await http.get(Uri.parse('http://13.231.75.235:8080/profiles')); // TODO: edit this to real URI in production
    
    // OK status
    if (response.statusCode == 200) {
      var converted = decoder.convert(response.body);
      for (var element in converted) {
        ret.add(Profile(element['name'], element['id'], element['age'], element['bio'], element['pfp']));     
      }
      return ret;
    } else {
      throw Exception('Failed to load album');
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
                Text(profile.bio.length > 30 ? profile.bio.substring(0, 30)+'...' : profile.bio),
              ],
            )
          ],
        ),
      ),
      );
  }


}

