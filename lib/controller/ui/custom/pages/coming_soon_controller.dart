import 'dart:async';

import 'package:original_taste/controller/my_controller.dart';

class ComingSoonController extends MyController {
  late Timer timer;
  Duration remaining = Duration();

  final DateTime launchDate = DateTime.now().add(Duration(days: 169));

  @override
  void onInit() {
    startCountdown();
    super.onInit();
  }

  void startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();

      remaining = launchDate.difference(now);
      update();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');
}
