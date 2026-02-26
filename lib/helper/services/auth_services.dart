import 'package:get/get.dart';
import 'package:original_taste/helper/services/api_helper.dart';

// ==================== ROLE CONSTANTS ====================
// Thêm role mới vào đây, không cần sửa chỗ nào khác (trừ AppRoutes bên dưới)
class AppRole {
  static const String admin      = 'ADMIN';
  static const String pos        = 'POS';
  static const String seller     = 'SELLER';       // TODO: triển khai sau
  static const String accountant = 'ACCOUNTANT';   // TODO: triển khai sau
  static const String shipper    = 'SHIPPER';       // TODO: triển khai sau
  static const String warehouse  = 'WAREHOUSE';    // TODO: triển khai sau
}

// ==================== ROUTE CONSTANTS ====================
// Khi triển khai role mới:
//   1. Thêm entry vào roleHomeRoutes
//   2. Thêm GetPage tương ứng trong routes.dart
//   3. Bỏ comment TODO ở cả 2 nơi
class AppRoutes {
  static const String signIn = '/auth/sign_in';
  static const String signUp = '/auth/sign_up';

  static const Map<String, String> roleHomeRoutes = {
    AppRole.admin      : '/dashboard',
    AppRole.pos        : '/pos',
    AppRole.seller     : '/seller/home',      // TODO: tạo SellerHomeScreen
    AppRole.accountant : '/accountant/home',  // TODO: tạo AccountantHomeScreen
    AppRole.shipper    : '/shipper/home',      // TODO: tạo ShipperHomeScreen
    AppRole.warehouse  : '/warehouse/home',   // TODO: tạo WarehouseHomeScreen
  };

  /// Trả về home route của role, fallback về signIn nếu chưa có trong map
  static String homeForRole(String? role) {
    return roleHomeRoutes[role] ?? signIn;
  }
}

// ==================== AUTH RESPONSE MODEL ====================
class AuthResponse {
  final int userId;
  final String fullName;
  final bool isLock;
  final String role;
  final String accessToken;

  AuthResponse({
    required this.userId,
    required this.fullName,
    required this.isLock,
    required this.role,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      isLock: json['isLock'] ?? false,
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}

// ==================== AUTH SERVICE ====================
class AuthService {
  static bool isLoggedIn = false;
  static String? currentRole;

  // ---- ROLE GETTERS ----
  static bool get isAdmin      => currentRole == AppRole.admin;
  static bool get isPos        => currentRole == AppRole.pos;
  static bool get isSeller     => currentRole == AppRole.seller;
  static bool get isAccountant => currentRole == AppRole.accountant;
  static bool get isShipper    => currentRole == AppRole.shipper;
  static bool get isWarehouse  => currentRole == AppRole.warehouse;

  /// Dùng trong RoleMiddleware: kiểm tra currentRole có trong danh sách cho phép không
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

  // ---- LOGIN ----
  /// Trả về null nếu thành công, String thông báo lỗi nếu thất bại
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

    if (result.isSuccess && result.data != null) {
      final auth = result.data!;

      await SessionStorage.saveSession(
        accessToken: auth.accessToken,
        role: auth.role,
        fullName: auth.fullName,
        isLock: auth.isLock,
        userId: auth.userId,
      );

      // QUAN TRỌNG: set state TRƯỚC khi navigate
      // để RoleMiddleware và isAdmin getter có giá trị đúng ngay khi build widget
      isLoggedIn = true;
      currentRole = auth.role;

      _navigateByRole(auth.role);
      return null;
    }

    return getErrorMessage(result.code, result.message);
  }

  // ---- REGISTER ----
  /// Trả về null nếu thành công, String thông báo lỗi nếu thất bại
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
        'username': username,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
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
    isLoggedIn = false;
    currentRole = null;
    Get.offAllNamed(AppRoutes.signIn);
  }

  // ---- NAVIGATE BY ROLE ----
  static void _navigateByRole(String role) {
    final route = AppRoutes.homeForRole(role);

    if (route == AppRoutes.signIn) {
      // Role chưa có trong map → chưa triển khai
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