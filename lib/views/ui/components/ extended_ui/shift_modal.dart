import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShiftModal extends StatefulWidget {
  final VoidCallback onShiftOpened;
  final VoidCallback onShiftClosed;

  const ShiftModal({
    super.key,
    required this.onShiftOpened,
    required this.onShiftClosed,
  });

  @override
  State<ShiftModal> createState() => _ShiftModalState();
}

class _ShiftModalState extends State<ShiftModal> {
  bool _isShiftOpen = false;
  final String _shiftKey = 'is_shift_open';

  @override
  void initState() {
    super.initState();
    _loadShiftStatus();
  }

  Future<void> _loadShiftStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isShiftOpen = prefs.getBool(_shiftKey) ?? false;
    });
  }

  Future<void> _openShift() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shiftKey, true);
    setState(() => _isShiftOpen = true);
    widget.onShiftOpened(); // Gọi để HomePage rebuild
  }

  Future<void> _closeShift() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đóng ca làm việc?'),
        content: const Text('Bạn có chắc muốn đóng ca? Tất cả dữ liệu giỏ hàng sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đóng ca', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_shiftKey, false);
      setState(() => _isShiftOpen = false);
      widget.onShiftClosed(); // Gọi để HomePage rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isShiftOpen ? Icons.lock_open : Icons.lock_clock,
              size: 140,
              color: _isShiftOpen ? Colors.green : Colors.deepOrange,
            ),
            const SizedBox(height: 40),
            Text(
              _isShiftOpen ? 'Ca đang mở' : 'Chưa mở ca làm việc',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _isShiftOpen
                  ? 'Bạn có thể bắt đầu bán hàng'
                  : 'Vui lòng mở ca để bắt đầu bán hàng',
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              icon: Icon(_isShiftOpen ? Icons.power_settings_new : Icons.play_arrow),
              label: Text(
                _isShiftOpen ? 'Đóng ca' : 'Mở ca',
                style: const TextStyle(fontSize: 22),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isShiftOpen ? Colors.redAccent : Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isShiftOpen ? _closeShift : _openShift,
            ),
          ],
        ),
      ),
    );
  }
}