import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

import 'package:original_taste/helper/services/auth_services.dart';

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = true}); // Mặc định collapse

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.isCondensed; // Mặc định collapse (false)
  }

  // Hàm toggle expand/collapse
  void toggleExpand([bool force = false]) {
    setState(() {
      _isExpanded = force ? true : !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthService.currentRole;

    if (role == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Get.offAllNamed('/sign_in');
      });
      return const SizedBox.shrink();
    }

    const lightBg    = Colors.white;
    const lightText  = Colors.black87;
    final  lightIcon = Colors.grey[700]!;
    final  activeColor = Colors.blue[700]!;
    final  activeBg    = Colors.blue[50]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? 200 : 90,
      color: lightBg,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              children: [
                // Dashboard
                _MenuItem(
                  icon: Boxicons.bx_home_alt,
                  title: 'Dashboard',
                  route: _getHomeRoute(role),
                  isExpanded: _isExpanded,
                  activeColor: activeColor,
                  lightText: lightText,
                  lightIcon: lightIcon,
                  // ✅ Navigate + expand
                  onTap: () {
                    Get.offNamed(_getHomeRoute(role));
                    if (!_isExpanded) toggleExpand(true);
                  },
                ),

                // Render menu theo role
                if (role == 'ADMIN')     ..._adminMenus    (_isExpanded, activeColor, activeBg, lightText, lightIcon),
                if (role == 'SELLER')    ..._sellerMenus   (_isExpanded, activeColor, activeBg, lightText, lightIcon),
                if (role == 'SHIPER')    ..._shiperMenus   (_isExpanded, activeColor, activeBg, lightText, lightIcon),
                if (role == 'WAREHOUSE') ..._warehouseMenus(_isExpanded, activeColor, activeBg, lightText, lightIcon),
                if (role == 'POS')       ..._posMenus      (_isExpanded, activeColor, activeBg, lightText, lightIcon),
                if (role == 'ACCOUNTANT')..._accountantMenus(_isExpanded, activeColor, activeBg, lightText, lightIcon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHomeRoute(String role) {
    switch (role) {
      case 'SELLER':     return '/seller/home';
      case 'SHIPER':     return '/shiper/home';
      case 'WAREHOUSE':  return '/warehouse/home';
      case 'ACCOUNTANT': return '/accountant/home';
      case 'POS':        return '/pos';
      default:           return '/dashboard';
    }
  }

  List<Widget> _adminMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_cart,
      title: 'Orders',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'All Orders', route: '/orders/list', activeColor: activeColor),
        _SubMenuItem(title: 'New Orders', route: '/orders/new', activeColor: activeColor),
        _SubMenuItem(title: 'History', route: '/orders/history', activeColor: activeColor),
      ],
    ),
    _ExpansionMenuItem(
      icon: Boxicons.bx_package,
      title: 'Products',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'List', route: '/products/list', activeColor: activeColor),
        _SubMenuItem(title: 'Create', route: '/products/create', activeColor: activeColor),
        _SubMenuItem(title: 'Detail/Edit', route: '/products/detail', activeColor: activeColor),
      ],
    ),
    _ExpansionMenuItem(
      icon: Boxicons.bx_category,
      title: 'Category',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'List', route: '/categories/list', activeColor: activeColor),
        _SubMenuItem(title: 'Create', route: '/categories/create', activeColor: activeColor),
        _SubMenuItem(title: 'Detail/Edit', route: '/categories/detail', activeColor: activeColor),
      ],
    ),
  ];

  // Các hàm menu khác tương tự (SELLER, SHIPER, WAREHOUSE, POS, ACCOUNTANT) - anh copy và thêm onExpand: toggleExpand
  List<Widget> _sellerMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_cart,
      title: 'Order',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'New', route: '/orders/new', activeColor: activeColor),
        _SubMenuItem(title: 'Detail', route: '/orders/detail', activeColor: activeColor),
        _SubMenuItem(title: 'History', route: '/orders/history', activeColor: activeColor),
      ],
    ),

    _ExpansionMenuItem(
      icon: Boxicons.bx_cart,
      title: 'Customer',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'List', route: '/customer/list', activeColor: activeColor),
        _SubMenuItem(title: 'Detail', route: '/customer/detail', activeColor: activeColor),
      ],
    ),

    _ExpansionMenuItem(
      icon: Boxicons.bx_package,
      title: 'Inventory',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'History', route: '/inventory/history', activeColor: activeColor),
        _SubMenuItem(title: 'Import', route: '/inventory/import', activeColor: activeColor),
      ],
    ),

    _ExpansionMenuItem(
      icon: Boxicons.bx_package,
      title: 'Products',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'List', route: '/products/list', activeColor: activeColor),
        _SubMenuItem(title: 'Create', route: '/products/create', activeColor: activeColor),
        _SubMenuItem(title: 'Detail/Edit', route: '/products/detail', activeColor: activeColor),
      ],
    ),
    _ExpansionMenuItem(
      icon: Boxicons.bx_category,
      title: 'Ingredient',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'List', route: '/ingredient/list', activeColor: activeColor),
        _SubMenuItem(title: 'Create', route: '/ingredient/create', activeColor: activeColor),
        _SubMenuItem(title: 'Detail/Edit', route: '/ingredient/detail', activeColor: activeColor),
      ],
    ),
    _ExpansionMenuItem(
      icon: Boxicons.bx_category,
      title: 'Category',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'Invoice', route: '/invoice', activeColor: activeColor),
        _SubMenuItem(title: 'List', route: '/categories/list', activeColor: activeColor),
        _SubMenuItem(title: 'Create', route: '/categories/create', activeColor: activeColor),
        _SubMenuItem(title: 'Detail/Edit', route: '/categories/detail', activeColor: activeColor),
      ],
    ),


  ];

  List<Widget> _shiperMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_cart,
      title: 'Orders',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'Detail', route: '/orders/detail', activeColor: activeColor),
        _SubMenuItem(title: 'History', route: '/orders/history', activeColor: activeColor),
      ],
    ),
  ];

  List<Widget> _warehouseMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _ExpansionMenuItem(
      icon: Boxicons.bx_package,
      title: 'Inventory',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightIcon: lightIcon,
      onExpand: toggleExpand,
      children: [
        _SubMenuItem(title: 'History', route: '/inventory/history', activeColor: activeColor),
        _SubMenuItem(title: 'Import', route: '/inventory/import', activeColor: activeColor),
      ],
    ),
  ];

  List<Widget> _posMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bx_dollar_circle,
      title: 'POS',
      route: '/pos',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      onTap: () => Get.offNamed('/pos'),
    ),
  ];

  List<Widget> _accountantMenus(bool isExpanded, Color activeColor, Color activeBg, Color lightText, Color lightIcon) => [
    _MenuItem(
      icon: Boxicons.bx_package,
      title: 'Inventory History',
      route: '/inventory/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      onTap: () => Get.offNamed('/inventory/history'),
    ),
    _MenuItem(
      icon: Boxicons.bx_cart,
      title: 'Orders History',
      route: '/orders/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      onTap: () => Get.offNamed('/orders/history'),
    ),
    _MenuItem(
      icon: Boxicons.bx_buildings,
      title: 'Warehouse History',
      route: '/warehouse/history',
      isExpanded: isExpanded,
      activeColor: activeColor,
      lightText: lightText,
      lightIcon: lightIcon,
      onTap: () => Get.offNamed('/warehouse/history'),
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
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isExpanded,
    required this.activeColor,
    required this.lightText,
    required this.lightIcon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;

    return ListTile(
      leading: Icon(icon, color: isActive ? activeColor : lightIcon),
      title: !isExpanded ? const SizedBox.shrink() : MyText.bodyMedium(title, color: isActive ? activeColor : lightText),
      selected: isActive,
      selectedTileColor: Colors.blue[50],
      onTap: onTap,
    );
  }
}

// Widget menu có sub-items
class _ExpansionMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final List<Widget> children;
  final Color activeColor;
  final Color lightIcon;
  final VoidCallback? onExpand;

  const _ExpansionMenuItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.children,
    required this.activeColor,
    required this.lightIcon,
    this.onExpand,
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
      key: PageStorageKey(widget.title), // ✅ giữ state đúng
      initiallyExpanded: _isOpen,
      leading: Icon(widget.icon, color: widget.lightIcon),
      title: !widget.isExpanded
          ? const SizedBox.shrink()
          : MyText.bodyMedium(widget.title, color: widget.lightIcon),
      iconColor: widget.lightIcon,
      collapsedIconColor: widget.lightIcon,
      childrenPadding: const EdgeInsets.only(left: 16),
      onExpansionChanged: (expanded) {
        setState(() => _isOpen = expanded);
        if (expanded && !widget.isExpanded && widget.onExpand != null) {
          widget.onExpand!();
        }
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
      contentPadding: const EdgeInsets.only(left: 50),
      title: MyText.bodyMedium(title, color: isActive ? activeColor : Colors.grey[700]),
      onTap: () => Get.offNamed(route),
    );
  }
}