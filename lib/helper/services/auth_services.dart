// lib/helper/services/auth_services.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/api_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ==================== ROLE CONSTANTS ====================
class AppRole {
  static const String superadmin = 'SUPERADMIN';
  static const String admin      = 'ADMIN';
  static const String pos        = 'POS';
  static const String seller     = 'SELLER';
  static const String accountant = 'ACCOUNTANT';
  static const String shipper    = 'SHIPPER';
  static const String warehouse  = 'WAREHOUSE';
}

// ==================== ROUTE CONSTANTS ====================
class AppRoutes {
  static const String signIn = '/auth/sign_in';
  static const String signUp = '/auth/sign_up';

  static const Map<String, String> roleHomeRoutes = {
    AppRole.superadmin : '/superadmin/dashboard',
    AppRole.admin      : '/admin/dashboard',
    AppRole.pos        : '/pos',
    AppRole.seller     : '/seller/order',
    AppRole.accountant : '/accountant/home',
    AppRole.shipper    : '/shipper/home',
    AppRole.warehouse  : '/warehouse/home',
  };

  static String homeForRole(String? role) =>
      roleHomeRoutes[role] ?? signIn;
}

// ==================== AUTH RESPONSE MODEL ====================
class AuthResponse {
  final int    userId;
  final String fullName;
  final bool   isLock;
  final String role;
  final String accessToken;

  AuthResponse({
    required this.userId,
    required this.fullName,
    required this.isLock,
    required this.role,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    userId:      json['userId']      ?? 0,
    fullName:    json['fullName']    ?? '',
    isLock:      json['isLock']      ?? false,
    role:        json['role']        ?? '',
    accessToken: json['accessToken'] ?? '',
  );
}

// ==================== APP VERSION MODEL ====================
class AppVersionCheckResult {
  final bool   hasUpdate;
  final bool   updateRequired; // true → force, false → soft
  final String latestVersion;
  final String downloadUrl;
  final String message;

  const AppVersionCheckResult({
    this.hasUpdate      = false,
    this.updateRequired = false,
    this.latestVersion  = '',
    this.downloadUrl    = '',
    this.message        = '',
  });

  factory AppVersionCheckResult.noUpdate() =>
      const AppVersionCheckResult();

  factory AppVersionCheckResult.fromJson(Map<String, dynamic> j) =>
      AppVersionCheckResult(
        hasUpdate:      j['hasUpdate']      == true,
        updateRequired: j['updateRequired'] == true,
        latestVersion:  j['latestVersion']  as String? ?? '',
        downloadUrl:    j['downloadUrl']    as String? ?? '',
        message:        j['message']        as String? ??
            'Có phiên bản mới, vui lòng cập nhật.',
      );
}

// ==================== AUTH SERVICE ====================
class AuthService {
  static bool    isLoggedIn  = false;
  static String? currentRole;

  // ---- ROLE GETTERS ----
  static bool get isSuperAdmin => currentRole == AppRole.superadmin;
  static bool get isAdmin      => currentRole == AppRole.admin;
  static bool get isPos        => currentRole == AppRole.pos;
  static bool get isSeller     => currentRole == AppRole.seller;
  static bool get isAccountant => currentRole == AppRole.accountant;
  static bool get isShipper    => currentRole == AppRole.shipper;
  static bool get isWarehouse  => currentRole == AppRole.warehouse;

  static bool hasAccess(List<String> allowedRoles) {
    if (!isLoggedIn || currentRole == null) return false;
    return allowedRoles.contains(currentRole);
  }

  // ---- RESTORE SESSION ----
  static Future<void> restoreSession() async {
    isLoggedIn = await SessionStorage.isLoggedIn();
    if (isLoggedIn) {
      currentRole = await SessionStorage.getRole();
    }
  }

  // ---- VERSION CHECK ────────────────────────────────────────────
  /// Gọi /api/auth/version-check — không cần JWT, an toàn gọi trước login.
  /// Trả về NoUpdate nếu lỗi mạng → không block user.
  static Future<AppVersionCheckResult> checkVersion() async {
    try {
      final info     = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';
      final version  = info.version;      // "1.0.1"
      final build    = info.buildNumber;  // "8"


      final result = await ApiHelper.get<AppVersionCheckResult>(
        '/api/auth/version-check',
        queryParams: {'platform': platform, 'version': version, 'build': build},
        requireAuth: false,
        fromData: (d) => d != null
            ? AppVersionCheckResult.fromJson(d as Map<String, dynamic>)
            : AppVersionCheckResult.noUpdate(),
      );

      if (result.isSuccess && result.data != null) return result.data!;
      return AppVersionCheckResult.noUpdate();
    } catch (_) {
      return AppVersionCheckResult.noUpdate();
    }
  }

  // ---- LOGIN ----
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    final result = await ApiHelper.post<AuthResponse>(
      '/api/auth/login',
      body: {'username': username, 'password': password},
      requireAuth: false,
      fromData: (data) => data != null
          ? AuthResponse.fromJson(data as Map<String, dynamic>)
          : null,
    );

    if (result.isSuccess) {
      if (result.data != null) {
        final auth = result.data!;
        await SessionStorage.saveSession(
          accessToken: auth.accessToken,
          role:        auth.role,
          fullName:    auth.fullName,
          isLock:      auth.isLock,
          userId:      auth.userId,
        );
        isLoggedIn  = true;
        currentRole = auth.role;
        _navigateByRole(auth.role);
        return null;
      } else {
        getErrorMessage(result.code, result.message);
      }
    }
    return getErrorMessage(result.code, result.message);
  }

  // ---- REGISTER ----
  static Future<String?> register({
    required String username,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    final result = await ApiHelper.post<void>(
      '/api/auth/register',
      body: {
        'username':    username,
        'email':       email,
        'fullName':    fullName,
        'phoneNumber': phoneNumber,
        'password':    password,
      },
      requireAuth: false,
    );
    if (result.isSuccess) return null;
    return getErrorMessage(result.code, result.message);
  }

  // ---- LOGOUT ----
  static Future<void> logout() async {
    ApiHelper.post('/api/auth/logout', body: {}).ignore();
    await SessionStorage.clearSession();
    isLoggedIn  = false;
    currentRole = null;

    Get.deleteAll(force: true);
    await Future.delayed(const Duration(milliseconds: 100));
    Get.offAllNamed(AppRoutes.signIn);
  }

  // ---- NAVIGATE BY ROLE ----
  static void _navigateByRole(String role) {
    final route = AppRoutes.homeForRole(role);

    if (route == AppRoutes.signIn) {
      Get.snackbar(
        'Lỗi phân quyền',
        'Role "$role" chưa được hỗ trợ, vui lòng liên hệ quản trị viên',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    Get.offAllNamed(route);
  }
}