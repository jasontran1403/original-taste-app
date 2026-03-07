import 'package:flutter/scheduler.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

Future<void> safeOffAllNamed(
    String route, {
      dynamic arguments,
    }) async {
  // Đợi microtask queue drain (animation controller nhận được
  // tín hiệu stop từ TickerProvider)
  await Future.microtask(() {});

  // Đợi thêm 1 frame để RenderObject.dispose() hoàn tất
  await SchedulerBinding.instance.endOfFrame;

  Get.offAllNamed(route, arguments: arguments);
}
