import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/portlets_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/range_slider_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/scroll_bar_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/accordions_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/alerts_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/avatar_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/badges_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/breadcrumb_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/buttons_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/cards_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/carousel_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/collapse_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/dropdowns_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/embed_video_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/links_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/list_group_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/modals_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/notifications_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/pagination_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/placeholders_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/progress_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/spinners_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/tabs_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/tool_tip_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/typography_screen.dart';
import 'package:original_taste/views/ui/components/base_ui/utilities_screen.dart';
import 'package:original_taste/views/ui/components/chart_screen.dart';
import 'package:original_taste/views/ui/components/forms/basic_element_screen.dart';
import 'package:original_taste/views/ui/components/forms/file_uploads_screen.dart';
import 'package:original_taste/views/ui/components/forms/form_editor_screen.dart';
import 'package:original_taste/views/ui/components/forms/form_validation_screen.dart';
import 'package:original_taste/views/ui/components/forms/form_wizard_screen.dart';
import 'package:original_taste/views/ui/components/forms/x_editable_screen.dart';
import 'package:original_taste/views/ui/components/icon/remix_icon_screen.dart';
import 'package:original_taste/views/ui/components/map_screen.dart';
import 'package:original_taste/views/ui/components/table_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/lock_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/reset_password_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_in_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_up_screen.dart';
import 'package:original_taste/views/ui/custom/pages/coming_soon_screen.dart';
import 'package:original_taste/views/ui/custom/pages/error_404_alt_screen.dart';
import 'package:original_taste/views/ui/custom/pages/error_404_screen.dart';
import 'package:original_taste/views/ui/custom/pages/maintenance_screen.dart';
import 'package:original_taste/views/ui/custom/pages/pricing_screen.dart';
import 'package:original_taste/views/ui/custom/pages/time_line_screen.dart';
import 'package:original_taste/views/ui/custom/pages/welcome_screen.dart';
import 'package:original_taste/views/ui/custom/widget_screen.dart';
import 'package:original_taste/views/ui/general/attribute/attribute_create_screen.dart';
import 'package:original_taste/views/ui/general/attribute/attribute_edit_screen.dart';
import 'package:original_taste/views/ui/general/attribute/attribute_list_screen.dart';
import 'package:original_taste/views/ui/general/category/category_create_screen.dart';
import 'package:original_taste/views/ui/general/category/category_edit_screen.dart';
import 'package:original_taste/views/ui/general/category/category_list_screen.dart';
import 'package:original_taste/views/ui/general/dashboard.dart';
import 'package:original_taste/views/ui/general/inventory/received_orders_screen.dart';
import 'package:original_taste/views/ui/general/inventory/warehouse_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_create_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_details_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_list_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_cart_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_checkout_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_detail_screen.dart';
import 'package:original_taste/views/ui/general/orders/orders_list_screen.dart';
import 'package:original_taste/views/ui/general/product/product_create_screen.dart';
import 'package:original_taste/views/ui/general/product/product_detail_screen.dart';
import 'package:original_taste/views/ui/general/product/product_edit_screen.dart';
import 'package:original_taste/views/ui/general/product/product_grid_screen.dart';
import 'package:original_taste/views/ui/general/product/product_list_screen.dart';
import 'package:original_taste/views/ui/general/purchase/purchase_list_screen.dart';
import 'package:original_taste/views/ui/general/purchase/purchase_order_screen.dart';
import 'package:original_taste/views/ui/general/purchase/purchase_return_screen.dart';
import 'package:original_taste/views/ui/general/setting_screen.dart';
import 'package:original_taste/views/ui/other/coupons/coupons_add_screen.dart';
import 'package:original_taste/views/ui/other/coupons/coupons_list_screen.dart';
import 'package:original_taste/views/ui/other/reviews_screen.dart';
import 'package:original_taste/views/ui/other_app/calendar_screen.dart';
import 'package:original_taste/views/ui/other_app/chat_screen.dart';
import 'package:original_taste/views/ui/other_app/email_screen.dart';
import 'package:original_taste/views/ui/other_app/todo_screen.dart';
import 'package:original_taste/views/ui/support/faqs_screen.dart';
import 'package:original_taste/views/ui/support/help_center_screen.dart';
import 'package:original_taste/views/ui/support/privacy_policy_screen.dart';
import 'package:original_taste/views/ui/users/customers/customer_details_screen.dart';
import 'package:original_taste/views/ui/users/customers/customers_list_screen.dart';
import 'package:original_taste/views/ui/users/permission_screen.dart';
import 'package:original_taste/views/ui/users/profile_screen.dart';
import 'package:original_taste/views/ui/users/roles/roles_create_screen.dart';
import 'package:original_taste/views/ui/users/roles/roles_edit_screen.dart';
import 'package:original_taste/views/ui/users/roles/roles_list_screen.dart';
import 'package:original_taste/views/ui/users/sellers/seller_create_screen.dart';
import 'package:original_taste/views/ui/users/sellers/seller_details_screen.dart';
import 'package:original_taste/views/ui/users/sellers/seller_edit_screen.dart';
import 'package:original_taste/views/ui/users/sellers/seller_list_screen.dart';

// ==================== MIDDLEWARE ====================

/// Chỉ yêu cầu đăng nhập, không quan tâm role
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    return null;
  }
}

/// Middleware linh hoạt theo role.
///
/// Cách dùng: middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])]
///
/// Khi thêm role mới:
///   → Chỉ cần thêm AppRole vào list của các route phù hợp bên dưới
///   → Không cần tạo thêm Middleware class mới
class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware(this.allowedRoles);

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    if (!AuthService.hasAccess(allowedRoles)) {
      // Không có quyền → về home của role hiện tại
      return RouteSettings(name: AppRoutes.homeForRole(AuthService.currentRole));
    }
    return null;
  }
}

// ==================== ROUTES ====================

List<GetPage> getPageRoute() {
  var routes = [
    // -------------------------------------------------------
    // AUTH (không cần đăng nhập)
    // -------------------------------------------------------
    GetPage(name: AppRoutes.signIn,       page: () => SignInScreen()),
    GetPage(name: AppRoutes.signUp,       page: () => SignUpScreen()),
    GetPage(name: '/auth/reset_password', page: () => ResetPasswordScreen()),
    GetPage(name: '/auth/lock',           page: () => LockScreen()),

    // -------------------------------------------------------
    // HOME THEO ROLE
    // Khi triển khai role mới: bỏ comment GetPage tương ứng
    // và tạo Screen + bỏ comment trong AppRoutes.roleHomeRoutes
    // -------------------------------------------------------
    GetPage(
      name: '/dashboard',
      page: () => Dashboard(),
      middlewares: [RoleMiddleware([AppRole.admin])],
    ),
    GetPage(
      name: '/pos',
      page: () => PosScreen(),
      middlewares: [RoleMiddleware([AppRole.pos])],
    ),
    // TODO: Bỏ comment khi triển khai từng role
    // GetPage(name: '/seller/home',     page: () => SellerHomeScreen(),     middlewares: [RoleMiddleware([AppRole.seller])]),
    // GetPage(name: '/accountant/home', page: () => AccountantHomeScreen(), middlewares: [RoleMiddleware([AppRole.accountant])]),
    // GetPage(name: '/shipper/home',    page: () => ShipperHomeScreen(),    middlewares: [RoleMiddleware([AppRole.shipper])]),
    // GetPage(name: '/warehouse/home',  page: () => WarehouseHomeScreen(),  middlewares: [RoleMiddleware([AppRole.warehouse])]),

    // -------------------------------------------------------
    // ADMIN ONLY
    // -------------------------------------------------------
    GetPage(name: '/products/list',    page: () => ProductListScreen(),    middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/products/create',  page: () => ProductCreateScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/products/edit',    page: () => ProductEditScreen(),    middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/products/detail',  page: () => ProductDetailScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/products/grid',    page: () => ProductGridScreen(),    middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/category/list',    page: () => CategoryListScreen(),   middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/category/edit',    page: () => CategoryEditScreen(),   middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/category/create',  page: () => CategoryCreateScreen(), middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/attribute/list',   page: () => AttributeListScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/attribute/edit',   page: () => AttributeEditScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/attribute/create', page: () => AttributeCreateScreen(),middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/settings',         page: () => SettingScreen(),        middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/roles/list',       page: () => RolesListScreen(),      middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/roles/edit',       page: () => RolesEditScreen(),      middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/roles/create',     page: () => RolesCreateScreen(),    middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/permission',       page: () => PermissionScreen(),     middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/coupons/list',     page: () => CouponsListScreen(),    middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/coupons/add',      page: () => CouponsAddScreen(),     middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/customer/list',    page: () => CustomersListScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/customer/details', page: () => CustomerDetailsScreen(),middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/sellers/list',     page: () => SellerListScreen(),     middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/sellers/details',  page: () => SellerDetailsScreen(),  middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/sellers/edit',     page: () => SellerEditScreen(),     middlewares: [RoleMiddleware([AppRole.admin])]),
    GetPage(name: '/sellers/create',   page: () => SellerCreateScreen(),   middlewares: [RoleMiddleware([AppRole.admin])]),

    // -------------------------------------------------------
    // MULTI-ROLE
    // Khi thêm role mới, chỉ cần thêm AppRole vào list
    // -------------------------------------------------------
    GetPage(name: '/inventory/warehouse',
      page: () => WarehouseScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.warehouse])],
    ),
    GetPage(name: '/inventory/received_orders',
      page: () => ReceivedOrdersScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.warehouse])],
    ),
    GetPage(name: '/purchase/list',
      page: () => PurchaseListScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/purchase/order',
      page: () => PurchaseOrderScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/purchase/return',
      page: () => PurchaseReturnScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/invoices/list',
      page: () => InvoiceListScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/invoices/details',
      page: () => InvoiceDetailsScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/invoices/create',
      page: () => InvoiceCreateScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.accountant])],
    ),
    GetPage(name: '/orders/list',
      page: () => OrdersListScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.pos, AppRole.seller])],
    ),
    GetPage(name: '/orders/detail',
      page: () => OrderDetailScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.pos, AppRole.seller, AppRole.shipper])],
    ),
    GetPage(name: '/orders/cart',
      page: () => OrderCartScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.pos])],
    ),
    GetPage(name: '/orders/checkout',
      page: () => OrderCheckoutScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.pos])],
    ),
    GetPage(name: '/reviews',
      page: () => ReviewsScreen(),
      middlewares: [RoleMiddleware([AppRole.admin, AppRole.seller])],
    ),

    // -------------------------------------------------------
    // TẤT CẢ ROLE (chỉ cần đăng nhập)
    // -------------------------------------------------------
    GetPage(name: '/profile',         page: () => ProfileScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/chat',            page: () => ChatScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/email',           page: () => EmailScreen(),         middlewares: [AuthMiddleware()]),
    GetPage(name: '/calendar',        page: () => CalendarScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/todo',            page: () => TodoScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/help_center',     page: () => HelpCenterScreen(),    middlewares: [AuthMiddleware()]),
    GetPage(name: '/privacy_policy',  page: () => PrivacyPolicyScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/faqs',            page: () => FaqsScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/welcome',         page: () => WelcomeScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/widget',          page: () => WidgetScreen(),        middlewares: [AuthMiddleware()]),
    GetPage(name: '/coming_soon',     page: () => ComingSoonScreen(),    middlewares: [AuthMiddleware()]),
    GetPage(name: '/timeline',        page: () => TimeLineScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/pricing',         page: () => PricingScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/maintenance',     page: () => MaintenanceScreen(),   middlewares: [AuthMiddleware()]),
    GetPage(name: '/error_404',       page: () => Error404Screen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/error_404_alt',   page: () => Error404AltScreen(),   middlewares: [AuthMiddleware()]),
    GetPage(name: '/chart',                  page: () => ChartScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/table',                  page: () => TableScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/maps',                   page: () => MapScreen(),            middlewares: [AuthMiddleware()]),
    GetPage(name: '/icon/remix_icon',        page: () => RemixIconScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/basic_element',    page: () => BasicElementScreen(),   middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/validation',       page: () => FormValidationScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/file_upload',      page: () => FileUploadsScreen(),    middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/form_editors',     page: () => FormEditorScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/x_editable',       page: () => XEditableScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/forms/form_wizard',      page: () => FormWizardScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/accordions',  page: () => AccordionsScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/alerts',      page: () => AlertsScreen(),         middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/avatar',      page: () => AvatarScreen(),         middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/button',      page: () => ButtonsScreen(),        middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/badges',      page: () => BadgesScreen(),         middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/breadcrumb',  page: () => BreadcrumbScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/card',        page: () => CardsScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/carousel',    page: () => CarouselScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/collapse',    page: () => CollapseScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/dropdown',    page: () => DropdownsScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/embed_video', page: () => EmbedVideoScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/links',       page: () => LinksScreen(),          middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/list_group',  page: () => ListGroupScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/modals',      page: () => ModalsScreen(),         middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/notification',page: () => NotificationsScreen(),  middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/placeholders',page: () => PlaceholdersScreen(),   middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/pagination',  page: () => PaginationScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/progress',    page: () => ProgressScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/spinner',     page: () => SpinnersScreen(),       middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/tab',         page: () => TabsScreen(),           middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/tooltip',     page: () => ToolTipScreen(),        middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/typography',  page: () => TypographyScreen(),     middlewares: [AuthMiddleware()]),
    GetPage(name: '/components/utilities',   page: () => UtilitiesScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/extended_ui/range_slider',page: () => RangeSliderScreen(),   middlewares: [AuthMiddleware()]),
    GetPage(name: '/extended_ui/scrollbar',  page: () => ScrollBarScreen(),      middlewares: [AuthMiddleware()]),
    GetPage(name: '/extended_ui/portlets',   page: () => PortletsScreen(),       middlewares: [AuthMiddleware()]),
  ];

  return routes
      .map((e) => GetPage(
    name: e.name,
    page: e.page,
    middlewares: e.middlewares,
    transition: Transition.noTransition,
  ))
      .toList();
}