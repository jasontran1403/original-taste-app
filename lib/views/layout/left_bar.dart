import 'package:flutter_svg/flutter_svg.dart';
import 'package:original_taste/helper/services/url_service.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:remixicon/remixicon.dart';

typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static void attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static void detachListener(String key) => observers.remove(key);

  static void notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = false});

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  bool isCondensed = false;
  String path = UrlService.getCurrentUrl();

  @override
  Widget build(BuildContext context) {
    isCondensed = widget.isCondensed;
    return MyCard(
      paddingAll: 0,
      shadow: MyShadow(position: MyShadowPosition.centerRight, elevation: 0.2),
      child: AnimatedContainer(
        color: leftBarTheme.background,
        // width: 75,
        width: isCondensed ? 75 : 280,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Padding(
                padding: MySpacing.x(20),
                child: Row(
                  mainAxisAlignment: widget.isCondensed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: !widget.isCondensed
                          ? Image.asset(customizer.leftBarTheme == ThemeMode.system ? Images.darkLogo : Images.lightLogo, height: 24)
                          : Image.asset(Images.smLogo, height: 24),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  physics: BouncingScrollPhysics(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  children: [
                    labelWidget("GENERAL"),
                    NavigationItem(iconData: 'assets/svg/widget_5.svg', title: "Analytics", isCondensed: isCondensed, route: '/dashboard/analytics'),
                    MenuWidget(
                      iconData: "assets/svg/t_shirt.svg",
                      isCondensed: isCondensed,
                      title: "Products",
                      children: [
                        MenuItem(title: 'List', route: '/products/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Grid', route: '/products/grid', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Detail', route: '/products/detail', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Edit', route: '/products/edit', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/products/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/clipboard_list.svg",
                      isCondensed: isCondensed,
                      title: "Category",
                      children: [
                        MenuItem(title: 'List', route: '/category/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Edit', route: '/category/edit', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/category/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/box.svg",
                      isCondensed: isCondensed,
                      title: "Inventory",
                      children: [
                        MenuItem(title: 'Warehouse', route: '/inventory/warehouse', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Received Orders', route: '/inventory/received_orders', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/bag_smile_bold.svg",
                      isCondensed: isCondensed,
                      title: "Orders",
                      children: [
                        MenuItem(title: 'List', route: '/orders/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Detail', route: '/orders/detail', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Cart', route: '/orders/cart', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Check Out', route: '/orders/checkout', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/card_send.svg",
                      isCondensed: isCondensed,
                      title: "Purchase",
                      children: [
                        MenuItem(title: 'List', route: '/purchase/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Order', route: '/purchase/order', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Return', route: '/purchase/return', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/confetti_minimalistic.svg",
                      isCondensed: isCondensed,
                      title: "Attribute",
                      children: [
                        MenuItem(title: 'List', route: '/attribute/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Edit', route: '/attribute/edit', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/attribute/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/bill_list.svg",
                      isCondensed: isCondensed,
                      title: "Invoices",
                      children: [
                        MenuItem(title: 'List', route: '/invoices/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Details', route: '/invoices/details', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/invoices/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    NavigationItem(iconData: 'assets/svg/settings.svg', title: "Settings", isCondensed: isCondensed, route: '/settings'),
                    labelWidget("USERS"),
                    NavigationItem(iconData: 'assets/svg/chat_square_like.svg', title: "Profile", isCondensed: isCondensed, route: '/profile'),
                    MenuWidget(
                      iconData: "assets/svg/user_speak_rounded.svg",
                      isCondensed: isCondensed,
                      title: "Roles",
                      children: [
                        MenuItem(title: 'List', route: '/roles/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Edit', route: '/roles/edit', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/roles/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    NavigationItem(
                      iconData: 'assets/svg/checklist_minimalistic.svg',
                      title: "Permission",
                      isCondensed: isCondensed,
                      route: '/permission',
                    ),
                    MenuWidget(
                      iconData: "assets/svg/users_group_two_rounded.svg",
                      isCondensed: isCondensed,
                      title: "Customers",
                      children: [
                        MenuItem(title: 'List', route: '/customer/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Details', route: '/customer/details', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/shop.svg",
                      isCondensed: isCondensed,
                      title: "Sellers",
                      children: [
                        MenuItem(title: 'List', route: '/sellers/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Details', route: '/sellers/details', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Edit', route: '/sellers/edit', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Create', route: '/sellers/create', isCondensed: widget.isCondensed),
                      ],
                    ),
                    labelWidget("OTHERS"),
                    MenuWidget(
                      iconData: "assets/svg/leaf_bold.svg",
                      isCondensed: isCondensed,
                      title: "Coupons",
                      children: [
                        MenuItem(title: 'List', route: '/coupons/list', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Add', route: '/coupons/add', isCondensed: widget.isCondensed),
                      ],
                    ),
                    NavigationItem(iconData: 'assets/svg/chat_square_like.svg', title: "Reviews", isCondensed: isCondensed, route: '/reviews'),
                    labelWidget("OTHER APPS"),
                    NavigationItem(iconData: 'assets/svg/chat_round.svg', title: "Chat", isCondensed: isCondensed, route: '/chat'),
                    NavigationItem(iconData: 'assets/svg/mailbox.svg', title: "Email", isCondensed: isCondensed, route: '/email'),
                    NavigationItem(iconData: 'assets/svg/calendar.svg', title: "Calendar", isCondensed: isCondensed, route: '/calendar'),
                    NavigationItem(iconData: 'assets/svg/checklist.svg', title: "Todo", isCondensed: isCondensed, route: '/todo'),
                    labelWidget("SUPPORT"),
                    NavigationItem(iconData: 'assets/svg/help.svg', title: "Help Center", isCondensed: isCondensed, route: '/help_center'),
                    NavigationItem(iconData: 'assets/svg/question_circle.svg', title: "FAQs", isCondensed: isCondensed, route: '/faqs'),
                    NavigationItem(
                      iconData: 'assets/svg/document_text.svg',
                      title: "Privacy Policy",
                      isCondensed: isCondensed,
                      route: '/privacy_policy',
                    ),
                    labelWidget("Custom"),
                    MenuWidget(
                      iconData: "assets/svg/gift.svg",
                      isCondensed: isCondensed,
                      title: "Pages",
                      children: [
                        MenuItem(title: 'Welcome', route: '/welcome', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Coming Soon', route: '/coming_soon', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Timeline', route: '/timeline', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Pricing', route: '/pricing', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Maintenance', route: '/maintenance', isCondensed: widget.isCondensed),
                        MenuItem(title: '404 ERROR', route: '/error_404', isCondensed: widget.isCondensed),
                        MenuItem(title: '404 ERROR (alt)', route: '/error_404_alt', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/lock_keyhole_duotone.svg",
                      isCondensed: isCondensed,
                      title: "Authentication",
                      children: [
                        MenuItem(title: 'Sign In', route: '/auth/sign_in', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Sign Up', route: '/auth/sign_up', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Reset Password', route: '/auth/reset_password', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Lock Screen', route: '/auth/lock', isCondensed: widget.isCondensed),
                      ],
                    ),
                    NavigationItem(iconData: 'assets/svg/atom.svg', title: "Widgets", isCondensed: isCondensed, route: '/widget'),
                    labelWidget("COMPONENTS"),
                    MenuWidget(
                      iconData: "assets/svg/bookmark_square.svg",
                      isCondensed: isCondensed,
                      title: "Base UI",
                      children: [
                        MenuItem(title: 'Accordion', route: '/components/accordions', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Alerts', route: '/components/alerts', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Avatars', route: '/components/avatar', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Buttons', route: '/components/button', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Badges', route: '/components/badges', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Breadcrumb', route: '/components/breadcrumb', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Card', route: '/components/card', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Carousel', route: '/components/carousel', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Collapse', route: '/components/collapse', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Dropdown', route: '/components/dropdown', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Embed Video', route: '/components/embed_video', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Links', route: '/components/links', isCondensed: widget.isCondensed),
                        MenuItem(title: 'List Group', route: '/components/list_group', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Modals', route: '/components/modals', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Notifications', route: '/components/notification', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Placeholders', route: '/components/placeholders', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Pagination', route: '/components/pagination', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Progress', route: '/components/progress', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Spinner', route: '/components/spinner', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Tabs', route: '/components/tab', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Tooltips', route: '/components/tooltip', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Typography', route: '/components/typography', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Utilities', route: '/components/utilities', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/case_round.svg",
                      isCondensed: isCondensed,
                      title: "Advanced UI",
                      children: [
                        MenuItem(title: 'Range Slider', route: '/extended_ui/range_slider', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Scrollbar', route: '/extended_ui/scrollbar', isCondensed: widget.isCondensed),
                        MenuItem(title: 'Portlets', route: '/extended_ui/portlets', isCondensed: widget.isCondensed),
                      ],
                    ),
                    MenuWidget(
                      iconData: "assets/svg/bookmark_square.svg",
                      isCondensed: isCondensed,
                      title: "Icons",
                      children: [MenuItem(title: 'Remix Icon', route: '/icon/remix_icon', isCondensed: widget.isCondensed)],
                    ),
                    NavigationItem(iconData: "assets/svg/pie_chart_2.svg", title: "Charts", isCondensed: isCondensed, route: '/chart'),
                    MenuWidget(
                      iconData: "assets/svg/book_bookmark.svg",
                      isCondensed: isCondensed,
                      title: "Forms",
                      children: [
                        MenuItem(title: "Basic Element", route: '/forms/basic_element', isCondensed: widget.isCondensed),
                        MenuItem(title: "Form Validation", route: '/forms/validation', isCondensed: widget.isCondensed),
                        MenuItem(title: "File Uploads", route: '/forms/file_upload', isCondensed: widget.isCondensed),
                        MenuItem(title: "Form Editors", route: '/forms/form_editors', isCondensed: widget.isCondensed),
                        MenuItem(title: "X Editable", route: '/forms/x_editable', isCondensed: widget.isCondensed),
                        MenuItem(title: "Form Wizard", route: '/forms/form_wizard', isCondensed: widget.isCondensed),
                      ],
                    ),
                    NavigationItem(iconData: "assets/svg/tuning_2.svg", title: "Table", isCondensed: isCondensed, route: '/table'),
                    NavigationItem(iconData: "assets/svg/streets_map_point.svg", title: "Maps", isCondensed: isCondensed, route: '/maps'),
                    MySpacing.height(20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget labelWidget(String label) {
    return isCondensed
        ? MySpacing.empty()
        : Container(
          padding: MySpacing.xy(24, 8),
          child: MyText.labelSmall(
            label.toUpperCase(),
            color: leftBarTheme.labelColor,
            muted: true,
            maxLines: 1,
            overflow: TextOverflow.clip,
            fontWeight: 700,
          ),
        );
  }
}

class MenuWidget extends StatefulWidget {
  final String? iconData;
  final String title;
  final bool isCondensed;
  final bool active;
  final String? route;
  final List<MenuItem> children;

  const MenuWidget({
    super.key,
    required this.iconData,
    required this.title,
    this.isCondensed = false,
    this.active = false,
    this.children = const [],
    this.route,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(bool value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.children.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (hide) => hideFn = hide,
        onChange: (value) {
          popupShowing = value;
        },
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },

          /// Small Side Bar
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(4, 0, 8, 8),
            borderRadiusAll: 8,
            padding: MySpacing.xy(4, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyContainer(height: 26, width: 3, paddingAll: 0, color: isActive || isHover ? leftBarTheme.activeItemColor : Colors.transparent),
                MySpacing.width(12),
                Center(
                  child: SvgPicture.asset(
                    widget.iconData!,
                    height: 22,
                    width: 22,
                    colorFilter: ColorFilter.mode((isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, BlendMode.srcIn),
                  ),
                ),
                // Icon(widget.iconData, color: (isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, size: 20),
              ],
            ),
          ),
        ),
        menuBuilder:
            (_) => MyContainer(
              borderRadiusAll: 8,
              paddingAll: 8,
              width: 210,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: widget.children),
            ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(0, 0, 4, 0),
          padding: MySpacing.x(8),
          child: ListTileTheme(
            contentPadding: EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
              tilePadding: MySpacing.zero,
              initiallyExpanded: isActive,
              maintainState: true,
              onExpansionChanged: (value) {
                LeftbarObserver.notifyAll(widget.title);
                onChangeExpansion(value);
              },
              trailing: RotationTransition(turns: _iconTurns, child: Icon(RemixIcons.arrow_down_s_line, size: 18, color: leftBarTheme.onBackground)),
              iconColor: leftBarTheme.activeItemColor,
              childrenPadding: MySpacing.x(12),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Large Side Bar
                  // MyContainer(height: 26, width: 5, paddingAll: 0, color: isActive || isHover ? leftBarTheme.activeItemColor : Colors.transparent),
                  MyContainer(
                    height: 32,
                    width: 3,
                    paddingAll: 0,
                    borderRadiusAll: 2,
                    color: isActive || isHover ? leftBarTheme.activeItemColor : Colors.transparent,
                  ),
                  MySpacing.width(12),
                  Center(
                    child: SvgPicture.asset(
                      widget.iconData!,
                      height: 22,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        (isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  // Icon(widget.iconData, size: 20, color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground),
                  MySpacing.width(18),
                  Expanded(
                    child: MyText.labelLarge(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                    ),
                  ),
                ],
              ),
              collapsedBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              backgroundColor: Colors.transparent,
              children: widget.children,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    LeftbarObserver.detachListener(widget.title);
  }
}

class MenuItem extends StatefulWidget {
  final String? iconData;
  final String title;
  final bool isCondensed;
  final String? route;
  final List<MenuItem> childrenMenuWidget;

  const MenuItem({super.key, this.iconData, required this.title, this.isCondensed = false, this.route, this.childrenMenuWidget = const []});

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(bool value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.childrenMenuWidget.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    if (widget.childrenMenuWidget.isEmpty) {
      return GestureDetector(
        onTap: () {
          if (widget.route != null) {
            print('Navigating to: ${widget.route}');  // debug
            Get.toNamed(widget.route!);
            // MyRouter.pushReplacementNamed(context, widget.route!, arguments: 1);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(4, 0, 8, 4),
            borderRadiusAll: 8,
            // color: isActive || isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
            width: MediaQuery.of(context).size.width,
            padding: MySpacing.xy(18, 7),
            child: MyText.bodySmall(
              widget.title,
              overflow: TextOverflow.clip,
              maxLines: 1,
              textAlign: TextAlign.left,
              fontSize: 12.5,
              color: isActive || isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
              fontWeight: isActive || isHover ? 600 : 500,
            ),
          ),
        ),
      );
    } else if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (hide) => hideFn = hide,
        onChange: (value) {
          popupShowing = value;
        },
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(16, 0, 16, 8),

            borderRadiusAll: 8,
            padding: MySpacing.xy(8, 8),
            child: Center(
              child: SvgPicture.asset(
                widget.iconData!,
                height: 22,
                width: 22,
                colorFilter: ColorFilter.mode((isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        menuBuilder:
            (_) => MyContainer(
              borderRadiusAll: 8,
              paddingAll: 8,
              width: 210,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: widget.childrenMenuWidget),
            ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(24, 0, 16, 0),
          paddingAll: 0,
          borderRadiusAll: 8,
          child: ListTileTheme(
            contentPadding: EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
              tilePadding: MySpacing.zero,
              initiallyExpanded: isActive,
              maintainState: true,
              onExpansionChanged: (value) {
                LeftbarObserver.notifyAll(widget.title);
                onChangeExpansion(value);
              },
              trailing: RotationTransition(
                turns: _iconTurns,
                // child: Icon(LucideIcons.chevron_down, size: 18, color: leftBarTheme.onBackground),
              ),
              iconColor: leftBarTheme.activeItemColor,
              childrenPadding: MySpacing.x(12),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(widget.iconData, size: 20, color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground),
                  SvgPicture.asset(
                    widget.iconData!,
                    height: 22,
                    width: 22,
                    colorFilter: ColorFilter.mode((isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, BlendMode.srcIn),
                  ),
                  MySpacing.width(18),
                  Expanded(
                    child: MyText.labelLarge(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                    ),
                  ),
                ],
              ),
              collapsedBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              backgroundColor: Colors.transparent,
              children: widget.childrenMenuWidget,
            ),
          ),
        ),
      );
    }
  }
}

class NavigationItem extends StatefulWidget {
  final String? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const NavigationItem({super.key, this.iconData, required this.title, this.isCondensed = false, this.route});

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          Get.toNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(0, 0, 8, 8),
          borderRadiusAll: 8,
          padding: MySpacing.xy(4, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyContainer(
                height: 32,
                width: 3,
                paddingAll: 0,
                borderRadiusAll: 2,
                color: isActive || isHover ? leftBarTheme.activeItemColor : Colors.transparent,
              ),
              MySpacing.width(16),
              if (widget.iconData != null)
                Center(
                  child: SvgPicture.asset(
                    widget.iconData!,
                    height: 22,
                    width: 22,
                    colorFilter: ColorFilter.mode((isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, BlendMode.srcIn),
                  ),
                ),
              if (!widget.isCondensed) Flexible(fit: FlexFit.loose, child: MySpacing.width(16)),
              if (!widget.isCondensed)
                Expanded(
                  flex: 3,
                  child: MyText.labelLarge(
                    widget.title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    color: isHover || isActive ? leftBarTheme.activeItemColor : leftBarTheme.onBackground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
