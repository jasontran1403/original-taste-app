import 'dart:math';

import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/role_list_model.dart';

class RolesListController extends MyController {
  List<RoleListModel> roleList = [];

  final List<Color> backgroundColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
    Colors.pink.shade100,
    Colors.brown.shade100,
    Colors.amber.shade100,
    Colors.deepOrange.shade100,
  ];

  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    loadRoles();
  }

  Future<void> loadRoles() async {
    roleList = await RoleListModel.dummyList;
    update();
  }

  void userActiveToggle(RoleListModel role, bool newValue) {
    role.active = newValue;
    update();
  }

  Color getRandomBgColor() => backgroundColors[_random.nextInt(backgroundColors.length)];
}