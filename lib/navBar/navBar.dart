import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sms_encry/constant/constant.dart';
import 'package:sms_encry/screens/allSms.dart';
import 'package:sms_encry/screens/contactScreen.dart';

class navBar extends StatefulWidget {
  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;

    _controller = PersistentTabController(initialIndex: 0);
    List<Widget> _buildScreens() {
      return [
        ContactScreen(),
        allSms(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          // iconSize: 25,
          icon: Image.asset(
            "assets/images/contact.png",
            height: 25,
          ),
          title: ("Contacts"),
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.black,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.chat_bubble_2_fill),
          title: ("Messages"),
          activeColorPrimary: primaryColor,
          inactiveColorPrimary: Colors.black,
        ),
      ];
    }

    return Scaffold(
        body: PersistentTabView(
      context,
      navBarHeight: 70,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,

      //, //? Default is Colors.white.
      handleAndroidBackButtonPress: true, //? Default is true.
      resizeToAvoidBottomInset:
          true, //? This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, //? Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, //? Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(25), topLeft: Radius.circular(25)),
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        //? Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        //? Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1,
    ));
  }
}
