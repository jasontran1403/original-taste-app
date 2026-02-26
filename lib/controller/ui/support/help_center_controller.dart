import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/images.dart';

class HelpCenterController extends MyController {
  final List<Map<String, dynamic>> cardData = [
    {
      "icon": Icons.arrow_circle_right,
      "title": "Getting Started with Larkon",
      "desc": "Welcome to Larkon Dive into basic for a swift on boarding experience",
      "author": "Aston Martin",
      "avatar": Images.userAvatars[0],
      "videoCount": 19
    },
    {
      "icon": Icons.admin_panel_settings,
      "title": "Admin Settings",
      "desc": "Learn how to manage your current workspace or your enterprise space",
      "author": "Michael A. Miner",
      "avatar": Images.userAvatars[1],
      "videoCount": 10
    },
    {
      "icon": Icons.desktop_windows,
      "title": "Server Setup",
      "desc": "Connect, simplify, and automate. Discover the power of apps and tools.",
      "author": "Theresa T. Brose",
      "avatar": Images.userAvatars[2],
      "videoCount": 7
    },
    {
      "icon": Icons.login,
      "title": "Login And Verification",
      "desc": "Read on to learn how to sign in with your email address, or your Apple or Google.",
      "author": "James L. Erickson",
      "avatar": Images.userAvatars[3],
      "videoCount": 3
    },
    {
      "icon": Icons.account_circle,
      "title": "Account Setup",
      "desc": "Adjust your profile and preferences to make ChatCloud work just for you",
      "author": "Lily Wilson",
      "avatar": Images.userAvatars[4],
      "videoCount": 11
    },
    {
      "icon": Icons.handshake,
      "title": "Trust & Safety",
      "desc": "Trust on our current database and learn how we distribute your data.",
      "author": "Sarah Brooks",
      "avatar": Images.userAvatars[5],
      "videoCount": 9
    },
    {
      "icon": Icons.settings,
      "title": "Channel Setup",
      "desc": "From channels to search, learn how ChatCloud works from top to bottom.",
      "author": "Joe K. Hall",
      "avatar": Images.userAvatars[6],
      "videoCount": 14
    },
    {
      "icon": Icons.vpn_key,
      "title": "Permissions",
      "desc": "Permission for you and others to join and work within a workspace",
      "author": "Robert Leavitt",
      "avatar": Images.userAvatars[7],
      "videoCount": 17
    },
    {
      "icon": Icons.attach_money,
      "title": "Billing Help",
      "desc": "That feel when you look at your bank account and billing works.",
      "author": "Lydia Anderson",
      "avatar": Images.userAvatars[8],
      "videoCount": 12
    },
  ];

}