import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';

class PermissionController extends MyController {
  List<bool> selected = [];
  String selectedOption = 'This Month';

  final List<Task> tasks = [
    Task(name: "User Management", roles: [Role("Manager", Colors.blue.shade100, Colors.blue)], created: "4 Mar 2023, 08:30 am", updated: "Today"),
    Task(
      name: "Financial Management",
      roles: [Role("Administrator", Colors.cyan.shade100, Colors.cyan), Role("Developer", Colors.grey.shade300, Colors.black)],
      created: "27 Jun 2024, 12:00 am",
      updated: "Yesterday",
    ),
    Task(
      name: "Content Management",
      roles: [Role("Manager", Colors.blue.shade100, Colors.blue), Role("Administrator", Colors.cyan.shade100, Colors.cyan)],
      created: "02 Dec 2023, 02:30 am",
      updated: "06 Dec 2023",
    ),
    Task(
      name: "Payroll",
      roles: [
        Role("Manager", Colors.blue.shade100, Colors.blue),
        Role("Administrator", Colors.cyan.shade100, Colors.cyan),
        Role("Analyst", Colors.green.shade100, Colors.green),
        Role("Trial", Colors.orange.shade100, Colors.orange),
      ],
      created: "27 Jun 2024, 12:00 am",
      updated: "14 May 2024",
    ),
    Task(
      name: "Reporting",
      roles: [
        Role("Manager", Colors.blue.shade100, Colors.blue),
        Role("Trial", Colors.orange.shade100, Colors.orange),
        Role("Developer", Colors.grey.shade300, Colors.black),
      ],
      created: "13 Aug 2024, 07:05 am",
      updated: "Today",
    ),
    Task(
      name: "API Controls",
      roles: [Role("Manager", Colors.blue.shade100, Colors.blue), Role("Analyst", Colors.green.shade100, Colors.green)],
      created: "28 Sep 2023, 01:20 pm",
      updated: "10 Oct 2023",
    ),
    Task(
      name: "Disputes Management",
      roles: [Role("Manager", Colors.blue.shade100, Colors.blue), Role("Developer", Colors.grey.shade300, Colors.black)],
      created: "10 Feb 2025, 06:00 pm",
      updated: "Yesterday",
    ),
    Task(
      name: "Database Management",
      roles: [
        Role("Manager", Colors.blue.shade100, Colors.blue),
        Role("Administrator", Colors.cyan.shade100, Colors.cyan),
        Role("Developer", Colors.grey.shade300, Colors.black),
      ],
      created: "19 Jul 2024, 09:45 pm",
      updated: "Yesterday",
    ),
    Task(
      name: "Repository Management",
      roles: [Role("Administrator", Colors.cyan.shade100, Colors.cyan), Role("Developer", Colors.grey.shade300, Colors.black)],
      created: "05 Jan 2024, 11:00 am",
      updated: "03 Dec 2023",
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selected = List<bool>.filled(tasks.length, false);
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }
}

class Task {
  final String name;
  final List<Role> roles;
  final String created;
  final String updated;

  Task({required this.name, required this.roles, required this.created, required this.updated});
}

class Role {
  final String title;
  final Color color;
  final Color textColor;

  Role(this.title, this.color, this.textColor);
}
