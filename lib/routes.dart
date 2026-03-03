import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/views/seller/order_history_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/lock_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/reset_password_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_in_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_up_screen.dart';
import 'package:original_taste/views/ui/custom/pages/welcome_screen.dart' hide WelcomeScreen;
import 'package:original_taste/views/ui/general/category/category_create_screen.dart';
import 'package:original_taste/views/ui/general/category/category_edit_screen.dart';
import 'package:original_taste/views/ui/general/category/category_list_screen.dart' hide CategoryEditScreen;
import 'package:original_taste/views/ui/general/inventory/inventory_history_screen.dart';
import 'package:original_taste/views/ui/general/inventory/warehouse_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_create_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_details_screen.dart';
import 'package:original_taste/views/ui/general/invoice/invoice_list_screen.dart';
import 'package:original_taste/views/ui/general/material/ingredient_create_screen.dart';
import 'package:original_taste/views/ui/general/material/ingredient_edit_screen.dart';
import 'package:original_taste/views/ui/general/material/ingredient_list_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_cart_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_detail_screen.dart';
import 'package:original_taste/views/ui/general/orders/orders_list_screen.dart';
import 'package:original_taste/views/ui/general/product/product_create_screen.dart';
import 'package:original_taste/views/ui/general/product/product_detail_screen.dart';
import 'package:original_taste/views/ui/general/product/product_edit_screen.dart';
import 'package:original_taste/views/ui/general/product/product_list_screen.dart';
import 'package:original_taste/views/ui/general/warehouse_dashboard.dart';
import 'package:original_taste/views/layout/welcome_screen.dart';
import 'package:original_taste/views/ui/general/seller_dashboard.dart';
import 'package:original_taste/views/ui/general/accountant_dashboard.dart';
import 'package:original_taste/views/ui/general/admin_dashboard.dart';
import 'package:original_taste/views/ui/general/shiper_dashboard.dart';

// ==================== MIDDLEWARE ====================

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;
  RoleMiddleware(this.allowedRoles);

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    if (!AuthService.hasAccess(allowedRoles)) {
      return RouteSettings(name: AppRoutes.homeForRole(AuthService.currentRole));
    }
    return null;
  }
}

// ==================== ROUTES ====================

List<GetPage> getPageRoute() {
  return [
    // ── Auth screens (full-screen, không có Layout shell) ──
    GetPage(name: '/welcome',             page: () => WelcomeScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.signIn,       page: () => SignInScreen()),
    GetPage(name: AppRoutes.signUp,       page: () => SignUpScreen()),
    GetPage(name: '/auth/reset_password', page: () => ResetPasswordScreen()),
    GetPage(name: '/auth/lock',           page: () => LockScreen()),

    // ── Dashboard (home của từng role) ──
    // Dùng transition: Transition.noTransition để không có animation "swipe screen"
    // Layout shell (LeftBar, TopBar) nằm trong mỗi Dashboard/Screen widget.
    GetPage(
      name: '/dashboard',
      page: () => AdminDashboard(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN'])],
    ),
    GetPage(
      name: '/seller/home',
      page: () => SellerDashboard(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER'])],
    ),
    GetPage(
      name: '/shiper/home',
      page: () => ShiperDashboard(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SHIPER'])],
    ),
    GetPage(
      name: '/warehouse/home',
      page: () => WarehouseDashboard(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['WAREHOUSE'])],
    ),
    GetPage(
      name: '/accountant/home',
      page: () => AccountantDashboard(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ACCOUNTANT'])],
    ),
    GetPage(
      name: '/pos',
      page: () => PosScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['POS'])],
    ),

    // ── Orders ──
    GetPage(
      name: '/orders/list',
      page: () => OrdersListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER', 'SHIPER'])],
    ),
    GetPage(
      name: '/orders/new',
      page: () => OrderCartScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER', 'SHIPER'])],
    ),
    GetPage(
      name: '/orders/detail',
      page: () => OrderDetailScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER', 'SHIPER'])],
    ),
    GetPage(
      name: '/orders/history',
      page: () => OrderHistoryScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER', 'SHIPER', 'ACCOUNTANT'])],
    ),

    // ── Products ──
    GetPage(
      name: '/products/list',
      page: () => ProductListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/products/create',
      page: () => ProductCreateScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/products/edit',
      page: () => ProductEditScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/products/detail',
      page: () => ProductDetailScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    GetPage(
      name: '/invoice',
      page: () => InvoiceDetailsScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    // ── Categories ──
    GetPage(
      name: '/categories/list',
      page: () => CategoryListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/categories/create',
      page: () => CategoryCreateScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/categories/edit',
      page: () => CategoryEditScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    GetPage(
      name: '/ingredient/list',
      page: () => IngredientListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/ingredient/create',
      page: () => IngredientCreateScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/ingredient/edit',
      page: () => IngredientEditScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    // ── Inventory ──
    GetPage(
      name: '/inventory/history',
      page: () => InventoryHistoryScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['WAREHOUSE', 'ACCOUNTANT', 'SELLER', 'ADMIN'])],
    ),
    GetPage(
      name: '/inventory/import',
      page: () => InventoryImportScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['WAREHOUSE', 'SELLER', 'ADMIN'])],
    ),
  ];
}