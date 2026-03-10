// views/layout/left_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/services/auth_services.dart';

class LeftBar extends StatefulWidget {
  final bool isCondensed;
  final Function(bool)? onToggle;

  const LeftBar({super.key, this.isCondensed = true, this.onToggle});

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _menuOpacityAnimation;
  late Animation<Offset> _menuSlideAnimation;

  String get role => AuthService.currentRole ?? 'GUEST';


  // ── Theme listener ─────────────────────────────────────────────────
  void _onThemeChange(ThemeCustomizer oldVal, ThemeCustomizer newVal) {
    if (mounted) setState(() {});
  }

  bool get _isDark =>
      ThemeCustomizer.instance.theme == ThemeMode.dark;

  // ── Màu theo theme ─────────────────────────────────────────────────
  Color get _bg =>
      _isDark ? const Color(0xff22282e) : Colors.white;

  Color get _textColor =>
      _isDark ? const Color(0xffe0e4ea) : Colors.black87;

  Color get _iconColor =>
      _isDark ? const Color(0xff8a94a6) : Colors.grey.shade700;

  Color get _activeColor =>
      _isDark ? const Color(0xff5b9cf6) : Colors.blue.shade700;

  Color get _activeBg =>
      _isDark ? const Color(0xff2d3a4a) : Colors.blue.shade50;

  Color get _dividerColor =>
      _isDark ? const Color(0xff2e3640) : Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;

    ThemeCustomizer.addListener(_onThemeChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _widthAnimation = Tween<double>(begin: 80, end: 180).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _menuOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _menuSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
        );
  }

  void toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onToggle?.call(_isExpanded);
    });
  }

  @override
  void dispose() {
    ThemeCustomizer.removeListener(_onThemeChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (role == 'GUEST') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/sign_in');
      });
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: _widthAnimation.value,
              // Animasi warna background saat theme berubah
              color: _bg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Toggle button ──────────────────────────────────
                  GestureDetector(
                    onTap: toggleExpand,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 60,
                      width: 60,
                      margin: EdgeInsets.only(
                        top: _isExpanded ? 80 : 10,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(_isDark ? 90 : 60),
                            blurRadius: 12,
                            offset: const Offset(3, 3),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: _activeColor.withAlpha(50),
                            blurRadius: 15,
                            offset: Offset.zero,
                            spreadRadius: _isExpanded ? 3 : 1,
                          ),
                        ],
                        border: Border.all(
                          color: _activeColor.withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 400),
                          turns: _isExpanded ? 0.5 : 0,
                          child: Icon(
                            _isExpanded
                                ? Boxicons.bx_chevron_left
                                : Boxicons.bx_chevron_right,
                            color: _activeColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Menu items ─────────────────────────────────────
                  if (_isExpanded)
                    Expanded(
                      child: FadeTransition(
                        opacity: _menuOpacityAnimation,
                        child: SlideTransition(
                          position: _menuSlideAnimation,
                          child: ListView(
                            shrinkWrap: true,
                            padding:
                            const EdgeInsets.symmetric(vertical: 20),
                            children: [
                              if (role == 'SUPERADMIN')
                                ..._superadminMenus(),
                              if (role == 'ADMIN')
                                ..._adminMenus(),
                              if (role == 'SELLER')
                                ..._sellerMenus(),
                              if (role == 'SHIPER')
                                ..._shiperMenus(),
                              if (role == 'WAREHOUSE')
                                ..._warehouseMenus(),
                              if (role == 'POS')
                                ..._posMenus(),
                              if (role == 'ACCOUNTANT')
                                ..._accountantMenus(),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Helper: tạo _MenuItem với theme hiện tại ─────────────────────
  _MenuItem _item({
    required IconData icon,
    required String title,
    required String route,
    VoidCallback? onTap,
  }) =>
      _MenuItem(
        icon: icon,
        title: title,
        route: route,
        isExpanded: _isExpanded,
        activeColor: _activeColor,
        activeBg: _activeBg,
        textColor: _textColor,
        iconColor: _iconColor,
        isDark: _isDark,
        onTap: onTap ?? () => Get.toNamed(route),
      );

  _ExpansionMenuItem _expItem({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) =>
      _ExpansionMenuItem(
        icon: icon,
        title: title,
        isExpanded: _isExpanded,
        activeColor: _activeColor,
        iconColor: _iconColor,
        textColor: _textColor,
        isDark: _isDark,
        children: children,
      );

  String _homeRoute() {
    switch (role) {
      case 'SELLER':     return '/seller/order';
      case 'SHIPER':     return '/shiper/home';
      case 'WAREHOUSE':  return '/warehouse/home';
      case 'ACCOUNTANT': return '/accountant/home';
      case 'POS':        return '/pos';
      case 'SUPERADMIN':      return '/superadmin/dashboard';
      case 'ADMIN':      return '/admin/dashboard';
      default:           return '/auth/sign_in';
    }
  }

  // ── Menu lists ────────────────────────────────────────────────────
  List<Widget> _superadminMenus() => [
    _item(icon: Boxicons.bx_home_alt,    title: 'Dashboard', route: _homeRoute()),
    _item(icon: Boxicons.bxs_cart,       title: 'Order',      route: '/seller/order'),
    _item(icon: Boxicons.bx_package,     title: 'Product',    route: '/seller/product'),
    _item(icon: Boxicons.bxs_component,  title: 'Ingredient', route: '/seller/ingredient'),
    _item(icon: Boxicons.bx_category,    title: 'Category',   route: '/seller/category'),
  ];

  List<Widget> _adminMenus() => [
    _item(icon: Boxicons.bx_home_alt,    title: 'Dashboard', route: _homeRoute()),
  ];

  List<Widget> _sellerMenus() => [
    _item(icon: Boxicons.bxs_cart,      title: 'Order',      route: '/seller/order'),
    _item(icon: Boxicons.bx_package,    title: 'Product',    route: '/seller/product'),
    _item(icon: Boxicons.bxs_component, title: 'Ingredient', route: '/seller/ingredient'),
    _item(icon: Boxicons.bx_category,   title: 'Category',   route: '/seller/category'),
  ];

  List<Widget> _shiperMenus() => [
    _expItem(
      icon: Boxicons.bx_cart,
      title: 'Orders',
      children: [
        _SubMenuItem(title: 'Detail',  route: '/orders/detail',  activeColor: _activeColor, isDark: _isDark),
        _SubMenuItem(title: 'History', route: '/orders/history', activeColor: _activeColor, isDark: _isDark),
      ],
    ),
  ];

  List<Widget> _warehouseMenus() => [
    _expItem(
      icon: Boxicons.bx_package,
      title: 'Inventory',
      children: [
        _SubMenuItem(title: 'History', route: '/inventory/history', activeColor: _activeColor, isDark: _isDark),
        _SubMenuItem(title: 'Import',  route: '/inventory/import',  activeColor: _activeColor, isDark: _isDark),
      ],
    ),
  ];

  List<Widget> _posMenus() => [
    _item(icon: Boxicons.bx_dollar_circle, title: 'POS', route: '/pos'),
  ];

  List<Widget> _accountantMenus() => [
    _item(icon: Boxicons.bx_package,   title: 'Inventory History', route: '/inventory/history'),
    _item(icon: Boxicons.bx_cart,      title: 'Orders History',    route: '/orders/history'),
    _item(icon: Boxicons.bx_buildings, title: 'Warehouse History', route: '/warehouse/history'),
  ];
}

// ── _MenuItem ─────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isExpanded;
  final Color activeColor;
  final Color activeBg;
  final Color textColor;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isExpanded,
    required this.activeColor,
    required this.activeBg,
    required this.textColor,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? activeColor : iconColor,
      ),
      title: isExpanded
          ? MyText.bodyMedium(
        title,
        color: isActive ? activeColor : textColor,
        fontWeight: isActive ? 700 : 500,
        textAlign: TextAlign.left,
      )
          : null,
      horizontalTitleGap: 0,
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 16 : (90 - 24) / 2,
        vertical: 4,
      ),
      selected: isActive,
      selectedTileColor: activeBg,
      // Hover/splash màu phù hợp dark mode
      hoverColor: isDark
          ? Colors.white.withAlpha(12)
          : Colors.grey.withAlpha(20),
      onTap: onTap,
    );
  }
}

// ── _ExpansionMenuItem ────────────────────────────────────────────────
class _ExpansionMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final List<Widget> children;
  final Color activeColor;
  final Color iconColor;
  final Color textColor;
  final bool isDark;

  const _ExpansionMenuItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.children,
    required this.activeColor,
    required this.iconColor,
    required this.textColor,
    required this.isDark,
    super.key,
  });

  @override
  State<_ExpansionMenuItem> createState() => _ExpansionMenuItemState();
}

class _ExpansionMenuItemState extends State<_ExpansionMenuItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Override divider color để không bị màu mặc định đè lên
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        key: PageStorageKey(widget.title),
        initiallyExpanded: _isOpen,
        leading: Icon(widget.icon, color: widget.iconColor),
        title: widget.isExpanded
            ? MyText.bodyMedium(widget.title, color: widget.textColor)
            : const SizedBox.shrink(),
        iconColor: widget.iconColor,
        collapsedIconColor: widget.iconColor,
        // Nền tile theo dark mode
        backgroundColor: widget.isDark
            ? const Color(0xff1e2329)
            : Colors.grey.shade50,
        collapsedBackgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.only(left: 16),
        tilePadding: EdgeInsets.symmetric(
          horizontal: widget.isExpanded ? 16 : (90 - 24) / 2,
          vertical: 0,
        ),
        onExpansionChanged: (expanded) =>
            setState(() => _isOpen = expanded),
        children: widget.children,
      ),
    );
  }
}

// ── _SubMenuItem ──────────────────────────────────────────────────────
class _SubMenuItem extends StatelessWidget {
  final String title;
  final String route;
  final Color activeColor;
  final bool isDark;

  const _SubMenuItem({
    required this.title,
    required this.route,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;
    final textColor = isDark
        ? (isActive ? activeColor : const Color(0xff8a94a6))
        : (isActive ? activeColor : Colors.grey.shade700);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 50, right: 16),
      title: MyText.bodyMedium(title, color: textColor, textAlign: TextAlign.left),
      onTap: () => Get.toNamed(route),
    );
  }
}