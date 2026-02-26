import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  DateTime applied(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String getMonthName({bool short = true}) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final fullMonth = monthNames[month - 1];
    return short ? fullMonth.substring(0, 3) : fullMonth;
  }
}
