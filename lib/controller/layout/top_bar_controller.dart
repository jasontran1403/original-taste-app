import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/images.dart';

class TopBarController extends MyController {
  bool isHovered = false;
  bool isHoveredSetting = false;
  bool isHoveredNotification = false;

  void toggleRightBar(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  List message = [
    {"sender": "Cristina Pride", "time": "1 day ago", "message": "Hi, How are you? What about our next meeting", "avatar": Images.userAvatars[1]},
    {"sender": "Sam Garret", "time": "2 day ago", "message": "Yeah everything is fine", "avatar": Images.userAvatars[2]},
    {"sender": "Karen Robinson", "time": "2 day ago", "message": "Wow that's great", "avatar": Images.userAvatars[3]},
    {"sender": "Sherry Marshall", "time": "3 day ago", "message": "Hi, How are you? What about our next meeting", "avatar": Images.userAvatars[4]},
    {"sender": "Shawn Millard", "time": "4 day ago", "message": "Yeah everything is fine", "avatar": Images.userAvatars[5]},
  ];
  final List<Map<String, dynamic>> notifications = [
    {
      'avatar': 'assets/users/avatar-1.jpg',
      'message': 'Josephine Thompson commented on admin panel "Wow 😍! this admin looks good and awesome design"',
    },
    {'initial': 'D', 'name': 'Donoghue Susan', 'message': 'Hi, How are you? What about our next meeting', 'color': Colors.lightBlue},
    {
      'avatar': 'assets/users/avatar-3.jpg',
      'name': 'Jacob Gines',
      'message': 'Answered to your comment on the cash flow forecast\'s graph 🔔.',
    },
    {'icon': Icons.comment, 'message': 'You have received 20 new messages in the conversation', 'color': Colors.orange},
    {'avatar': 'assets/users/avatar-5.jpg', 'name': 'Shawn Bunch', 'message': 'Commented on Admin'},
  ];
}
