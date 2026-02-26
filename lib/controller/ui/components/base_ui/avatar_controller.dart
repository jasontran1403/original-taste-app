import 'package:original_taste/controller/my_controller.dart';

import 'package:original_taste/images.dart';

class AvatarController extends MyController {
  List<String> images =[
    Images.userAvatars[1],
    Images.userAvatars[2],
    Images.userAvatars[3],
    Images.userAvatars[4],
  ];

  final List<AvatarData> avatars = [
    AvatarData(imageUrl: Images.userAvatars[1]),
    AvatarData(imageUrl: Images.userAvatars[3]),
    AvatarData(title: 'K'),
    AvatarData(title: '9+'),
  ];
}


class AvatarData {
  final String? imageUrl;
  final String? title;

  AvatarData({
    this.imageUrl,
    this.title
  });
}
