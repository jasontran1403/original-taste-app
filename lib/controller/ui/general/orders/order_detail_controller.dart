import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';

class OrderDetailController extends MyController {
  final List<ProgressStep> steps = [
    ProgressStep("Order Confirming", 1.0, Colors.green, false),
    ProgressStep("Payment Pending", 1.0, Colors.green, false),
    ProgressStep("Processing", 0.6, Colors.orange, true),
    ProgressStep("Shipping", 0.0, Colors.blue, false),
    ProgressStep("Delivered", 0.0, Colors.blue, false),
  ];
}

class ProgressStep {
  final String label;
  final double progress;
  final Color color;
  final bool loading;

  ProgressStep(this.label, this.progress, this.color, this.loading);
}


class Product {
  final String imagePath;
  final String name;
  final String size;
  final String status;
  final int quantity;
  final double price;
  final double text;
  final double amount;

  Product({
    required this.imagePath,
    required this.name,
    required this.size,
    required this.status,
    required this.quantity,
    required this.price,
    required this.text,
    required this.amount,
  });
}


class TimelineItem {
  final Widget icon;
  final String title;
  final String? subtitle;
  final String timestamp;
  final Widget? action;
  final Widget? extraWidget;

  TimelineItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.action,
    this.extraWidget,
  });
}
