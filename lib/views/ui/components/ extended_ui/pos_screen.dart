import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos/history_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos/menu_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos_components.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    print('Device model: ${iosInfo.model}');
  }

  runApp(const PosScreen());
}

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.grey[50],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange,
          brightness: Brightness.light,
        ).copyWith(secondary: Colors.deepOrangeAccent),
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<String> _pages = ['Home', 'Menu', 'History', 'Promos', 'Settings'];

  Widget _buildPage() {
    switch (_pages[_selectedIndex]) {
      case 'Home':
        return const PosComponents();
      case 'Menu':
        return const PosMenuScreen();
      case 'History':
        return const PosHistoryScreen();
      case 'Promos':
        return const Center(child: Text('Promos Page - Coming Soon', style: TextStyle(fontSize: 28, color: Colors.black54)));
      case 'Settings':
        return _SettingsPage();
      default:
        return const PosComponents();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.screen_rotation_alt, size: 100, color: Colors.deepOrange),
              const SizedBox(height: 30),
              const Text(
                'Vui lòng xoay ngang thiết bị',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Ứng dụng POS được thiết kế tối ưu cho chế độ ngang',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isTablet = MediaQuery.of(context).size.width > 800;
    final navWidth = isTablet ? 80.0 : 64.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar
          Container(
            width: navWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(3, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(_pages.length, (index) {
                        return _navItem(
                          icon: [
                            Icons.home_rounded,
                            Icons.menu_book_rounded,
                            Icons.history_rounded,
                            Icons.local_offer_rounded,
                            Icons.settings_rounded,
                          ][index],
                          label: _pages[index],
                          index: index,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung chính
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                top: isTablet ? 24 : 12,
                right: isTablet ? 12 : 12,
                bottom: isTablet ? 24 : 12,
                left: 12,
              ),
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.deepOrange : Colors.grey[700], size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.deepOrange : Colors.grey[700],
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SETTINGS PAGE ====================
class _SettingsPage extends StatelessWidget {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?\nCa làm việc hiện tại sẽ không bị ảnh hưởng.',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // Nút Hủy
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hủy', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          // Nút Đăng xuất
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Future.delayed(const Duration(milliseconds: 300));

              if (context.mounted) {
                await AuthService.logout();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 32),

          // Card logout
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
              ),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              subtitle: const Text(
                'Kết thúc phiên làm việc và quay về màn hình đăng nhập',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showLogoutDialog(context),
            ),
          ),

          // Có thể thêm các setting khác bên dưới sau này
        ],
      ),
    );
  }
}