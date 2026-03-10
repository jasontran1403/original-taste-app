import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:original_taste/controller/layout/top_bar_controller.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/widgets/custom_pop_menu.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.screensName});
  final String screensName;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin, UIMixin {
  bool isFullScreen = false;
  Function? hideFn;
  Function? languageHideFn;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  TopBarController controller = Get.put(TopBarController());

  void _showLogoutDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,   // ← quan trọng
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 360,
          padding: MySpacing.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyContainer.rounded(
                color: contentTheme.danger.withOpacity(0.12),
                paddingAll: 16,
                child: Icon(Boxicons.bx_log_out, size: 32, color: contentTheme.danger),
              ),
              MySpacing.height(16),
              MyText.titleMedium('Xác nhận đăng xuất',
                  fontWeight: 700, textAlign: TextAlign.center),
              MySpacing.height(8),
              MyText.bodyMedium('Bạn có chắc chắn muốn đăng xuất không?',
                  muted: true, textAlign: TextAlign.center),
              MySpacing.height(24),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MyButton.outlined(
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false),
                        borderColor: theme.colorScheme.outline.withOpacity(0.4),
                        padding: MySpacing.xy(0, 12),
                        child: MyText.labelLarge('Hủy', fontWeight: 600),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: MyButton(
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
                        backgroundColor: contentTheme.danger,
                        padding: MySpacing.xy(0, 12),
                        elevation: 0,
                        child: MyText.labelLarge('Đăng xuất',
                            fontWeight: 600, color: contentTheme.onDanger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await Future.delayed(const Duration(milliseconds: 120));
      AuthService.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return MyContainer(
          key: _key,
          height: 100,
          borderRadiusAll: 0,
          paddingAll: 0,
          color: topBarTheme.background,
          child: Row(
            children: [
              // Spacer đẩy icons về bên phải
              const Spacer(),

              // ── Dark mode toggle ──────────────────────────────
              MouseRegion(
                onEnter: (_) => setState(() => controller.isHovered = true),
                onExit:  (_) => setState(() => controller.isHovered = false),
                child: InkWell(
                  onTap: () {
                    ThemeCustomizer.setTheme(
                      ThemeCustomizer.instance.theme == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
                    ThemeCustomizer.notify();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/svg/moon.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        controller.isHovered
                            ? contentTheme.primary
                            : contentTheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              MySpacing.width(4),

              // ── Notification bell ─────────────────────────────
              MouseRegion(
                onEnter: (_) => setState(() => controller.isHoveredNotification = true),
                onExit:  (_) => setState(() => controller.isHoveredNotification = false),
                child: CustomPopupMenu(
                  backdrop: true,
                  onChange: (_) {},
                  offsetX: -260,
                  menu: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/svg/bell_bing_bold.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        controller.isHoveredNotification
                            ? contentTheme.primary
                            : contentTheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  menuBuilder: (_) => buildNotification(controller.notifications),
                ),
              ),
              MySpacing.width(8),

              // ── User avatar / account menu ────────────────────
              CustomPopupMenu(
                backdrop: true,
                hideFn: (fn) => languageHideFn = fn,
                onChange: (_) {},
                offsetX: -110,
                offsetY: 16,
                menu: MyContainer.rounded(
                  paddingAll: 0,
                  height: 32,
                  width: 32,
                  child: Image.asset(Images.userAvatars[1]),
                ),
                menuBuilder: (_) => buildAccountMenu(),
              ),
              MySpacing.width(20),
            ],
          ),
        );
      },
    );
  }

  // =====================================================================
  // NOTIFICATION PANEL
  // =====================================================================
  Widget buildNotification(List<Map<String, dynamic>> notifications) {
    return MyContainer.bordered(
      paddingAll: 0,
      borderRadiusAll: 8,
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Notifications", fontWeight: 700, muted: true),
                MyButton.text(
                  onPressed: () => notifications.clear(),
                  padding: MySpacing.zero,
                  splashColor: contentTheme.secondary.withAlpha(28),
                  msPadding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  child: MyText.labelMedium("Clear All", fontWeight: 600, xMuted: true),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          SizedBox(
            height: 270,
            child: notifications.isEmpty
                ? Center(
              child: MyText.bodyMedium(
                "No new notifications",
                muted: true,
                fontWeight: 500,
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return MyButton(
                  onPressed: () {},
                  elevation: 0,
                  borderRadiusAll: 0,
                  padding: MySpacing.xy(12, 14),
                  backgroundColor:
                  theme.colorScheme.surface.withValues(alpha: 0.03),
                  splashColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  child: Padding(
                    padding: MySpacing.all(8.0),
                    child: Row(children: [
                      _buildLeading(item),
                      MySpacing.width(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['name'] != null)
                              MyText.bodyMedium(item['name'], fontWeight: 600),
                            MyText.bodySmall(
                              item['message'] ?? '',
                              fontWeight: 500,
                              muted: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
            ),
          ),
          const Divider(height: 0),
          Center(
            child: MyButton(
              onPressed: () {},
              padding: MySpacing.xy(12, 10),
              backgroundColor: contentTheme.primary,
              msBackgroundColor: WidgetStatePropertyAll(contentTheme.primary),
              borderRadiusAll: 8,
              elevation: 0,
              child: MyText.labelMedium(
                "View All Notification",
                fontWeight: 600,
                xMuted: true,
                color: contentTheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(Map<String, dynamic> item) {
    if (item.containsKey('avatar')) {
      return MyContainer.rounded(
        height: 36, width: 36, paddingAll: 0,
        clipBehavior: Clip.antiAlias,
        child: Image.asset(item['avatar'], fit: BoxFit.cover),
      );
    } else if (item.containsKey('initial')) {
      return MyContainer.rounded(
        height: 36, width: 36,
        color: (item['color'] as Color?)?.withValues(alpha: 0.2) ?? Colors.grey.shade200,
        child: Center(child: Text(item['initial'],
            style: TextStyle(fontWeight: FontWeight.bold, color: item['color'] ?? Colors.black))),
      );
    } else if (item.containsKey('icon')) {
      return MyContainer.rounded(
        height: 36, width: 36, paddingAll: 0,
        color: (item['color'] as Color?)?.withValues(alpha: 0.2) ?? Colors.grey.shade100,
        child: Icon(item['icon'], size: 18, color: item['color'] ?? Colors.grey),
      );
    }
    return MyContainer.rounded(
      height: 36, width: 36, color: Colors.grey.shade300,
      child: const Icon(Icons.notifications_none, size: 18, color: Colors.black54),
    );
  }

  // =====================================================================
  // ACCOUNT MENU
  // =====================================================================
  Widget buildAccountMenu() {
    return MyContainer(
      borderRadiusAll: 8,
      paddingAll: 0,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.nBottom(12),
            child: MyText.labelMedium("Welcome!", fontWeight: 700, muted: true),
          ),
          MySpacing.height(12),
          MyButton(
            onPressed: () {
              languageHideFn?.call();
              Get.toNamed('/profile');
            },
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            borderRadiusAll: 0,
            padding: MySpacing.all(12),
            splashColor: theme.colorScheme.onSurface.withAlpha(20),
            backgroundColor: Colors.transparent,
            child: Row(children: [
              Icon(Boxicons.bx_user_circle, size: 16, color: contentTheme.onBackground),
              MySpacing.width(8),
              MyText.labelMedium("Profile", fontWeight: 700, muted: true),
            ]),
          ),
          const Divider(),
          MyButton(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              // Đóng dropdown trước — backdrop của CustomPopupMenu sẽ dismiss
              // bất kỳ thứ gì mở cùng lúc, kể cả dialog.
              // Delay 250ms để dropdown animation xong hẳn rồi mới show dialog.
              languageHideFn?.call();
              Future.delayed(const Duration(milliseconds: 250), () {
                if (mounted) _showLogoutDialog();
              });
            },
            borderRadiusAll: 0,
            padding: MySpacing.all(12),
            splashColor: theme.colorScheme.error.withAlpha(28),
            backgroundColor: Colors.transparent,
            child: Row(children: [
              Icon(Boxicons.bx_log_out, size: 16, color: contentTheme.danger),
              MySpacing.width(8),
              MyText.labelMedium("Log out", fontWeight: 700, muted: true,
                  color: contentTheme.danger),
            ]),
          ),
          MySpacing.height(12),
        ],
      ),
    );
  }

  Color getIconColor(String colorKey) {
    switch (colorKey) {
      case "text-primary":   return Colors.blue;
      case "text-warning":   return Colors.orange;
      case "text-danger":    return Colors.red;
      case "text-pink":      return Colors.pink;
      case "text-purple":    return Colors.purple;
      case "text-success":   return Colors.green;
      default:               return Colors.grey;
    }
  }

  Color getBackgroundColor(String bgKey) {
    switch (bgKey) {
      case "bg-primary-subtle": return Colors.blue.shade50;
      case "bg-warning-subtle": return Colors.orange.shade50;
      case "bg-danger-subtle":  return Colors.red.shade50;
      case "bg-pink-subtle":    return Colors.pink.shade50;
      case "bg-purple-subtle":  return Colors.purple.shade50;
      case "bg-success-subtle": return Colors.green.shade50;
      default:                  return Colors.grey.shade50;
    }
  }
}