import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
/* import 'package:url_launcher/url_launcher.dart'; */
import 'package:page_transition/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stopstalkapp/classes/user.dart';
import 'dart:developer';
import '../screens/profile.dart';
import '../utils/auth.dart';
import '../utils/api.dart';
import '../classes/user.dart';
import '../classes/searched_friends_class.dart';

import '../utils/platforms.dart' as platforms;

class FriendCard extends StatefulWidget {
  final Friends friend;
  final BuildContext context;
  final int i;
  final Animation animation;
  bool loggedIn;
  FriendCard(this.friend, this.context, this.i, this.animation,this.loggedIn);

  static const platformImgs = platforms.platformImgs;

  @override
  _FriendCardState createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  bool isFriend = false;

  final Tween<Offset> _offSetTween = Tween(
    begin: Offset(1, 0),
    end: Offset.zero,
  );

  @override
  void initState() {
    isFriend = widget.friend.isFriend;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: SlideTransition(
        position: _offSetTween.animate(widget.animation),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            color: Color(0XFFeeeeee),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //SizedBox(width: 20),
                        Flexible(
                          child: Padding(
                              padding: new EdgeInsets.only(
                                  left: 0.0, right: 6.0, top: 6.0, bottom: 6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 20),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: InkWell(
                                            child: Text(
                                              widget.friend.firstName +
                                                  " " +
                                                  widget.friend.lastName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .fade,
                                                      child: ProfileScreen(
                                                        handle: widget.friend
                                                            .stopStalkHandle,
                                                        isUserItself: false,
                                                        friend: widget.friend,
                                                      )));
                                            }),
                                      ),
                                    ],
                                  ),
                                  !widget.loggedIn?
                                  MaterialButton(
                                    onPressed: () async {
                                      final friendProfile =
                                          await getProfileFromHandle(
                                              widget.friend.stopStalkHandle);
                                      bool checkres = await markFriend(
                                          friendProfile.user.id.toString(),
                                          context);
                                      var handle =
                                          widget.friend.stopStalkHandle;
                                      if (!isFriend) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Added $handle to friend list'),
                                              elevation: 10,
                                              duration: Duration(seconds: 2)),
                                        );
                                        setState(() {
                                          isFriend = true;
                                        });
                                      } else {
                                        bool checkres = await unFriend(
                                            friendProfile.user.id.toString(),
                                            context);
                                        if (checkres) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Removed $handle from friend list'),
                                                elevation: 10,
                                                duration: Duration(seconds: 2)),
                                          );
                                          setState(() {
                                            isFriend = false;
                                          });
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Unable to remove friend at the moment'),
                                                elevation: 10,
                                                duration: Duration(seconds: 2)),
                                          );
                                        }
                                      }
                                    },
                                    color: isFriend
                                        ? Colors.green[300]
                                        : Theme.of(context).buttonColor,
                                    textColor: Colors.white,
                                    child: Icon(
                                      isFriend
                                          ? FontAwesomeIcons.user
                                          : FontAwesomeIcons.userPlus,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 16,
                                        left: 14,
                                        right: 14),
                                    shape: CircleBorder(),
                                  )
                                      :MaterialButton(onPressed:(){
                                      Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login to Add Friends'),
                                        elevation: 10,
                                        duration: Duration(seconds: 2)),
                                  );},
                                    color:Theme.of(context).buttonColor,
                                    textColor: Colors.white,
                                    child: Icon(FontAwesomeIcons.userPlus,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 16,
                                        left: 14,
                                        right: 14),
                                    shape: CircleBorder(),),
                                ],
                              )),
                        ),
                      ]),
                  Divider(
                    color: Colors.grey,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            children: List<Widget>.generate(
                                widget.friend.handles.length, (int index) {
                              return InputChip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        FriendCard.platformImgs[widget
                                            .friend.handles[index][0]
                                            .toLowerCase()],
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                label: Text(widget.friend.handles[index][1]),
                                elevation: 6,
                                onPressed: () {
                                  print('Handle got clicked');
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      /* RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                        onPressed: () {}, //Add To Friends
                        color: Color(0xFF2542ff),
                        icon: Icon(Icons.add),
                        label: Text('Add to Friends'),
                        textColor: Colors.white,
                      ) */
                    ],
                  )
                ],
              ),
            ),
          ),
        ), //new card
      ),
    );
  }

/* _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/
}
