import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orbital/Profile.dart';
import 'package:orbital/pages/other_profile.dart';

List<Profile> testProfiles = <Profile>[
  Profile('John', 
          '123sdfjkhfksl', 
          18, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),
  Profile('Mary', 
          'fasdlmjnkfa', 
          21, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),
  Profile('Slavroski', 
          'gfgkmlsadmnjgf', 
          55, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),
          Profile('John', 
          '123sdfjkhfksl', 
          18, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),
  Profile('Mary', 
          'fasdlmjnkfa', 
          21, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),Profile('John', 
          '123sdfjkhfksl', 
          18, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),
  Profile('Mary', 
          'fasdlmjnkfa', 
          21, 
          'its a dog eat dog world', 
          'assets/default_profile.png'),];

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int? metPpl = 123456; // TODO: use API to grab this
  List<Profile>? matchedProfiles = testProfiles; // TODO: using test profiles, remove in production 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
              child: Text('you have passed by $metPpl people',
              style: TextStyle(fontSize: 12))),
            Container(
              padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
              child: Text('Matched: ',
              style: TextStyle(fontSize: 24))),
              Container(
                height: 626,
                child: ListView(children: getCards())),
          ],
        ),
      ),
    );
  }


  // generate cards from list of profiles
  List<Card> getCards() {
    if (matchedProfiles == null) {
      return List.empty();
    } else {
      List<Card> ret = List.empty(growable: true);
      for (var profile in matchedProfiles!) {
        ret.add(makeProfileCards(profile));
      }
      return ret;
    }
  } 


  // template for profile cards
  Card makeProfileCards(Profile profile) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(15, 16, 15, 0), 
      color: Colors.amber,
      child: InkWell(
        onTap: ()=> {Navigator.push(context, 
                                    MaterialPageRoute(builder: (context) => otherProfile(profile: profile)))}, // goes to the profile page
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              child: Image(image: AssetImage(profile.pfp), 
                    width: 70,
                    height: 70,
                    ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,),
                Text(profile.age.toString(),),
                Text(profile.bio,),
              ],
            )
          ],
        ),
      ),
      );
  }


}

