import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';

class RolesCreateController extends MyController {
  final TextEditingController roleNameController = TextEditingController(text: "Workspace Manager");
  final TextEditingController userNameController = TextEditingController(text: "Gaston Lapierre");

  String? selectedWorkspace = "Facebook";

  final List<String> allTags = ["Manager", "Product", "Data", "Designer", "Supporter", "System Design", "QA"];

  List<String> selectedTags = ["Manager", "Data"];

  String userStatus = "Active";
}