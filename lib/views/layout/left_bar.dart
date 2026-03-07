// views/layout/left_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/services/auth_services.dart';

final String role = AuthService.currentRole ?? 'GUEST';

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

  @override
  void initState() {
    super.initState();
    _isExpanded = false;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _widthAnimation = Tween<double>(
      begin: 80,
      end: 180,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _menuOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _menuSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    if (_isExpanded) {
      _animationController.forward();
    }
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

    const lightBg = Colors.white;
    const lightText = Colors.black87;
    final lightIcon = Colors.grey[700]!;
    final activeColor = Colors.blue[700]!;
    final activeBg = Colors.blue[50]!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // LeftBar container với animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: _widthAnimation.value,
              color: lightBg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon toggle luôn hiển thị
                  GestureDetector(
                    onTap: toggleExpand,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 60,
                      width: 60,
                      margin: EdgeInsets.only(
                        top: _isExpanded ? 80 : 10, // Khi expand: cách top 40, khi collapse: cách top 10
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: lightBg,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(3, 3),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.blue.withAlpha(50),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                            spreadRadius: _isExpanded ? 3 : 1,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.withAlpha(80),
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
                            color: Colors.blue[700],
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Menu items với animation pop ra
                  if (_isExpanded)
                    Expanded(
                      child: FadeTransition(
                        opacity: _menuOpacityAnimation,
                        child: SlideTransition(
                          position: _menuSlideAnimation,
                          child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            children: [


                              if (role == 'ADMIN')
                                ..._adminMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
                              if (role == 'SELLER')
                                ..._sellerMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
                              if (role == 'SHIPER')
                                ..._shiperMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
                              if (role == 'WAREHOUSE')
                                ..._warehouseMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
                              if (role == 'POS')
                                ..._posMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
                              if (role == 'ACCOUNTANT')
                                ..._accountantMenus(_isExpanded, activeColor, activeBg,
                                    lightText, lightIcon),
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

  String _getHomeRoute(String role) {
    switch (role) {
      case 'SELLER':
        return '/seller/order';
      case 'SHIPER':
        return '/shiper/home';
      case 'WAREHOUSE':
        return '/warehouse/home';
      case 'ACCOUNTANT':
        return '/accountant/home';
      case 'POS':
        return '/pos';
      case 'ADMIN':
        return '/dashboard';
      default:
        return '/auth/sign_in';
    }
  }

  List<Widget> _adminMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bx_home_alt,
      title: 'Dashboard',
      route: _getHomeRoute(role),
      isExpanded: _isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () {
        Get.toNamed(_getHomeRoute(role));
      },
    ),

    _MenuItem(
      icon: Boxicons.bxs_cart,
      title: 'Order',
      route: '/seller/order',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/order'),
    ),

    _MenuItem(
      icon: Boxicons.bx_package,
      title: 'Product',
      route: '/seller/product',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/product'),
    ),
    _MenuItem(
      icon: Boxicons.bxs_component,
      title: 'Ingredient',
      route: '/seller/ingredient',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/ingredient'),
    ),
    _MenuItem(
      icon: Boxicons.bx_category,
      title: 'Category',
      route: '/seller/category',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/category'),
    ),
  ];

  List<Widget> _sellerMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bxs_cart,
      title: 'Order',
      route: '/seller/order',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/order'),
    ),

    _MenuItem(
      icon: Boxicons.bx_package,
      title: 'Product',
      route: '/seller/product',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/product'),
    ),
    _MenuItem(
      icon: Boxicons.bxs_component,
      title: 'Ingredient',
      route: '/seller/ingredient',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/ingredient'),
    ),
    _MenuItem(
      icon: Boxicons.bx_category,
      title: 'Category',
      route: '/seller/category',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/seller/category'),
    ),
  ];

  List<Widget> _shiperMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_cart,
      title: 'Orders',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      children: [
        _SubMenuItem(
            title: 'Detail', route: '/orders/detail', activeColor: activeColor),
        _SubMenuItem(
            title: 'History', route: '/orders/history', activeColor: activeColor),
      ],
    ),
  ];

  List<Widget> _warehouseMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_package,
      title: 'Inventory',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      children: [
        _SubMenuItem(
            title: 'History', route: '/inventory/history', activeColor: activeColor),
        _SubMenuItem(
            title: 'Import', route: '/inventory/import', activeColor: activeColor),
      ],
    ),
  ];

  List<Widget> _posMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bx_dollar_circle,
      title: 'POS',
      route: '/pos',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/pos'),
    ),
  ];

  List<Widget> _accountantMenus(bool isExpanded, Color activeColor, Color activeBg,
      Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bx_package,
      title: 'Inventory History',
      route: '/inventory/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/inventory/history'),
    ),
    _MenuItem(
      icon: Boxicons.bx_cart,
      title: 'Orders History',
      route: '/orders/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/orders/history'),
    ),
    _MenuItem(
      icon: Boxicons.bx_buildings,
      title: 'Warehouse History',
      route: '/warehouse/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      activeBg: activeBg,
      onTap: () => Get.toNamed('/warehouse/history'),
    ),
  ];
}

// Widget menu item đơn
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isExpanded;
  final Color activeColor;
  final Color lightText;
  final Color lightIcon;
  final Color activeBg;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isExpanded,
    required this.activeColor,
    required this.lightText,
    required this.lightIcon,
    required this.activeBg,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? activeColor : lightIcon,
      ),
      title: isExpanded
          ? MyText.bodyMedium(
        title,
        color: isActive ? activeColor : lightText,
        fontWeight: isActive ? 700 : 500,
        textAlign: TextAlign.left,
      )
          : null, // Không hiển thị title khi collapse
      horizontalTitleGap: 0,
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 16 : (90 - 24) / 2, // 24 là kích thước icon, căn giữa
        vertical: 4,
      ),
      selected: isActive,
      selectedTileColor: activeBg,
      onTap: onTap,
    );
  }
}

// Widget menu có sub-items - SỬA ĐỂ CĂN GIỮA ICON KHI COLLAPSE
class _ExpansionMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final List<Widget> children;
  final Color activeColor;
  final Color lightIcon;

  const _ExpansionMenuItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.children,
    required this.activeColor,
    required this.lightIcon,
    super.key,
  });

  @override
  State<_ExpansionMenuItem> createState() => _ExpansionMenuItemState();
}

class _ExpansionMenuItemState extends State<_ExpansionMenuItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey(widget.title),
      initiallyExpanded: _isOpen,
      leading: Icon(widget.icon, color: widget.lightIcon),
      title: widget.isExpanded
          ? MyText.bodyMedium(widget.title, color: widget.lightIcon)
          : const SizedBox.shrink(),
      iconColor: widget.lightIcon,
      collapsedIconColor: widget.lightIcon,
      childrenPadding: const EdgeInsets.only(left: 16),
      tilePadding: EdgeInsets.symmetric(
        horizontal: widget.isExpanded ? 16 : (90 - 24) / 2, // Căn giữa icon khi collapse
        vertical: 0,
      ),
      onExpansionChanged: (expanded) {
        setState(() => _isOpen = expanded);
      },
      children: widget.children,
    );
  }
}

// Widget sub-item
class _SubMenuItem extends StatelessWidget {
  final String title;
  final String route;
  final Color activeColor;

  const _SubMenuItem({
    required this.title,
    required this.route,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 50, right: 16),
      title: MyText.bodyMedium(
        title,
        color: isActive ? activeColor : Colors.grey[700],
        textAlign: TextAlign.left,
      ),
      onTap: () => Get.toNamed(route),
    );
  }
}