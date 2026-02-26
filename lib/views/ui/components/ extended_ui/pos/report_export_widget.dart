// ════════════════════════════════════════
// FILE: report_export_widget.dart
// ════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:original_taste/helper/services/pos_service.dart';
import 'package:original_taste/helper/services/api_helper.dart';

// ════════════════════════════════════════
// MAIN EXPORT BUTTON
// ════════════════════════════════════════

class ExportReportButton extends StatelessWidget {
  final PosShiftModel? selectedShift;

  const ExportReportButton({super.key, required this.selectedShift});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.send_outlined, color: Colors.deepOrange),
      tooltip: 'Gửi báo cáo Telegram',
      onPressed: () => _showExportMenu(context),
    );
  }

  void _showExportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExportMenuSheet(selectedShift: selectedShift),
    );
  }
}

// ════════════════════════════════════════
// BOTTOM SHEET
// ════════════════════════════════════════

class _ExportMenuSheet extends StatefulWidget {
  final PosShiftModel? selectedShift;
  const _ExportMenuSheet({required this.selectedShift});

  @override
  State<_ExportMenuSheet> createState() => _ExportMenuSheetState();
}

class _ExportMenuSheetState extends State<_ExportMenuSheet> {
  bool _isLoading = false;

  // Gọi API, trả về ngay, server xử lý ngầm rồi gửi Telegram
  Future<void> _triggerExport({int? shiftId, String? from, String? to}) async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await SessionStorage.getAccessToken();
      final Uri uri;
      if (shiftId != null) {
        uri = Uri.parse('${ApiHelper.baseUrl}/api/pos/reports/shift/$shiftId');
      } else {
        uri = Uri.parse('${ApiHelper.baseUrl}/api/pos/reports/range?from=$from&to=$to');
      }

      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = body['message'] as String? ?? 'Đang xử lý...';

      if (!mounted) return;
      Navigator.pop(context);

      messenger.showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.telegram, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Row(children: [
            Icon(Icons.telegram, color: Colors.teal),
            SizedBox(width: 8),
            Text('Gửi báo cáo lên Telegram',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ]),
          const SizedBox(height: 6),
          const Text('Báo cáo Excel sẽ được gửi vào nhóm Telegram',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),

          // Option 1: Ca đang chọn
          _ExportOption(
            icon: Icons.receipt_long,
            title: 'Gửi ca đang chọn',
            subtitle: widget.selectedShift != null
                ? 'Ca #${widget.selectedShift!.id} · ${widget.selectedShift!.staffName} · ${widget.selectedShift!.shiftDate}'
                : 'Chưa chọn ca nào',
            color: Colors.teal,
            enabled: widget.selectedShift != null && !_isLoading,
            onTap: () => _triggerExport(shiftId: widget.selectedShift!.id),
          ),

          const SizedBox(height: 12),

          // Option 2: Khoảng ngày
          _ExportOption(
            icon: Icons.date_range,
            title: 'Gửi theo khoảng ngày',
            subtitle: 'Chọn ngày bắt đầu và kết thúc (chỉ ca đã đóng)',
            color: Colors.deepOrange,
            enabled: !_isLoading,
            onTap: () async {
              // Đóng bottom sheet trước để tránh context bị deactivate
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              if (!context.mounted) return;
              final result = await showDialog<({String from, String to})>(
                context: context,
                builder: (ctx) => _DateRangeDialog(
                  onConfirm: (from, to) =>
                      Navigator.of(ctx).pop((from: from, to: to)),
                ),
              );
              if (result == null) return;
              // Gọi API sau khi dialog đóng, dùng messenger đã lưu
              _callRangeApi(messenger: messenger, from: result.from, to: result.to);
            },
          ),

          if (_isLoading) ...[
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                ),
                SizedBox(width: 10),
                Text('Đang gửi yêu cầu...', style: TextStyle(color: Colors.teal)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Dùng riêng cho range (sau khi sheet đã đóng, không còn context của sheet)
  Future<void> _callRangeApi({
    required ScaffoldMessengerState messenger,
    required String from,
    required String to,
  }) async {
    try {
      final token = await SessionStorage.getAccessToken();
      final uri = Uri.parse(
          '${ApiHelper.baseUrl}/api/pos/reports/range?from=$from&to=$to');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = body['message'] as String? ?? 'Đang xử lý...';
      messenger.showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.telegram, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

// ════════════════════════════════════════
// OPTION TILE
// ════════════════════════════════════════

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.enabled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? color.withOpacity(0.35) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: enabled ? color.withOpacity(0.12) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: enabled ? color : Colors.grey, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14,
                    color: enabled ? Colors.black87 : Colors.grey)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: enabled ? Colors.grey[600] : Colors.grey[400])),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: enabled ? color : Colors.grey[300], size: 20),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════
// DATE RANGE DIALOG
// ════════════════════════════════════════

class _DateRangeDialog extends StatefulWidget {
  final void Function(String from, String to) onConfirm;
  const _DateRangeDialog({required this.onConfirm});

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 6));
  DateTime _to   = DateTime.now();

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  String _display(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pick(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepOrange)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) { _from = picked; if (_from.isAfter(_to)) _to = _from; }
      else        { _to   = picked; if (_to.isBefore(_from)) _from = _to; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayDiff = _to.difference(_from).inDays + 1;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(children: [
        Icon(Icons.date_range, color: Colors.deepOrange),
        SizedBox(width: 8),
        Text('Chọn khoảng ngày'),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Xuất báo cáo cho các ca đã đóng trong $dayDiff ngày',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 20),
        _DatePickTile(
          label: 'Từ ngày', value: _display(_from),
          icon: Icons.calendar_today, onTap: () => _pick(true),
        ),
        const SizedBox(height: 12),
        _DatePickTile(
          label: 'Đến ngày', value: _display(_to),
          icon: Icons.event, onTap: () => _pick(false),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (dayDiff / 31.0).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ),
        const SizedBox(height: 4),
        Text('$dayDiff ngày',
            style: const TextStyle(
                fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.telegram, size: 18),
          label: const Text('Gửi Telegram'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => widget.onConfirm(_fmt(_from), _fmt(_to)),
        ),
      ],
    );
  }
}

class _DatePickTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickTile({
    required this.label, required this.value,
    required this.icon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepOrange.shade200),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const Spacer(),
          Icon(Icons.edit_calendar, size: 18, color: Colors.deepOrange.shade300),
        ]),
      ),
    );
  }
}