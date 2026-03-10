// lib/views/ui/general/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/controller/ui/general/dashboard_controller.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/general/pos_dashboard_screen.dart';

final _ct = AdminTheme.theme.contentTheme;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with UIMixin {
  late DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: controller,
      builder: (c) => Layout(
        screenName: 'DASHBOARD',
        child: Column(
          children: [
            _buildTopBar(c),
            const Divider(height: 0),
            Expanded(child: _buildModeContent(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(DashboardController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(child: _buildPeriodFilter(c)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: c.reload,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _ct.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.refresh, size: 18, color: _ct.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter(DashboardController c) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        ...DashboardPeriod.values
            .where((p) => p != DashboardPeriod.custom)
            .map((p) => _periodChip(c, p)),
        _customChip(c),
      ]),
    );
  }

  Widget _periodChip(DashboardController c, DashboardPeriod p) {
    final sel = c.period == p;
    return GestureDetector(
      onTap: () => c.setPeriod(p),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : _ct.secondary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _ct.primary : _ct.secondary.withOpacity(0.22)),
        ),
        child: Text(p.label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: sel ? _ct.onPrimary : null)),
      ),
    );
  }

  Widget _customChip(DashboardController c) {
    final sel = c.period == DashboardPeriod.custom;
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: c.customFrom != null && c.customTo != null
              ? DateTimeRange(start: c.customFrom!, end: c.customTo!)
              : null,
        );
        if (range != null) {
          c.setPeriod(DashboardPeriod.custom,
              from: range.start,
              to: range.end.copyWith(hour: 23, minute: 59, second: 59));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : _ct.secondary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _ct.primary : _ct.secondary.withOpacity(0.22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_outlined, size: 11,
              color: sel ? _ct.onPrimary : _ct.secondary),
          const SizedBox(width: 4),
          Text(
            sel && c.customFrom != null
                ? '${DateFormat('dd/MM').format(c.customFrom!)} – ${DateFormat('dd/MM').format(c.customTo!)}'
                : 'Tuỳ chọn',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: sel ? _ct.onPrimary : null),
          ),
        ]),
      ),
    );
  }

  Widget _buildModeContent(DashboardController c) {
    if (c.errorMsg.isNotEmpty) {
      return _buildError(c);
    }

    return const PosDashboardScreen();
  }

  Widget _buildError(DashboardController c) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 52, color: _ct.danger),
      MySpacing.height(12),
      MyText.bodyMedium(c.posErrorMsg, color: _ct.danger),
      MySpacing.height(16),
      ElevatedButton.icon(
        onPressed: c.reload,
        icon: const Icon(Icons.refresh),
        label: const Text('Thử lại'),
      ),
    ]),
  );
}