import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/reset_password_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_in_screen.dart';
import 'package:original_taste/views/ui/custom/authentication/sign_up_screen.dart';
import 'package:original_taste/views/ui/general/admin_dashboard_screen.dart';
import 'package:original_taste/views/ui/general/material/ingredient_list_screen.dart';
import 'package:original_taste/views/ui/general/orders/order_cart_screen.dart';
import 'package:original_taste/views/ui/general/product/product_detail_screen.dart';
import 'package:original_taste/views/ui/general/product/product_list_screen.dart';
import 'package:original_taste/views/ui/general/warehouse_dashboard.dart';
import 'package:original_taste/views/layout/welcome_screen.dart';
import 'package:original_taste/views/ui/general/accountant_dashboard.dart';
import 'package:original_taste/views/ui/general/shiper_dashboard.dart';

import 'controller/seller/category_list_controller.dart';

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

    GetPage(
      name: '/dashboard',
      page: () => AdminDashboardScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN'])],
    ),
    GetPage(
      name: '/seller/order',
      page: () => OrderCartScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER', 'ADMIN'])],
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

    GetPage(
      name: '/seller/order',
      page: () => OrderCartScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['SELLER', 'SHIPER', 'ADMIN'])],
    ),

    // ── Products ──
    GetPage(
      name: '/seller/product',
      page: () => ProductListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
    GetPage(
      name: '/products/detail',
      page: () => ProductDetailScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    // ── Categories ──
    GetPage(
      name: '/seller/category',
      page: () => CategoryListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),

    GetPage(
      name: '/seller/ingredient',
      page: () => IngredientListScreen(),
      transition: Transition.noTransition,
      middlewares: [RoleMiddleware(['ADMIN', 'SELLER'])],
    ),
  ];
}