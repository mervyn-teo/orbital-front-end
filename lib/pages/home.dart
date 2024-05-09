import 'package:flutter/material.dart';
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
Profile myProf = Profile('zhang haodong', 'dassdas', 2121, 'i love trains', 'assets/default_profile.png');

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int? metPpl = 123456; // TODO: use API to grab this
  List<Profile>? matchedProfiles = testProfiles; // TODO: using test profiles, remove in production 
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
        body: choosePage(pageIndex),
      ),
        );
  }

  Widget choosePage(pageIndex) {
    switch (pageIndex) {
          case 0:
            return matchedPage();
          case 1:
            return Container();
          case 2:
            return Container();
          case 3:
            return myProfile();
          default:
            return matchedPage();
        }
  }

  //generate page for my profile
  Widget myProfile() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Card(
            elevation: 4,
            shape: CircleBorder(),
            child: CircleAvatar(
              radius: 70,
              child: Image(
                image: AssetImage(myProf.pfp)
              )
            )
          )
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 26, 0, 0),
          child: MaterialButton(
            child: Text('Edit', style: TextStyle(color: Colors.white, fontSize: 20),),
            color: Colors.amber,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () => {}),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 26, 0, 0),
          child: Text(myProf.name, style: TextStyle(fontSize: 24),)),
        Container(
          margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Text(myProf.age.toString(), style: TextStyle(fontSize: 18),)),
        Container(
          margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Text(myProf.bio, style: TextStyle(fontSize: 12),)),
      ],
    );
  }

  // generate page for matched
  Widget matchedPage() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            height: 550,
            child: ListView(children: getCards())
          )
        ]
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

