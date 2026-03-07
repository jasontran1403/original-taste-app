import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==================== CONSTANTS ====================
const String _baseUrl = 'https://ghoul-helpful-salmon.ngrok-free.app';

const String _keyAccessToken = 'access_token';
const String _keyRole        = 'role';
const String _keyFullName    = 'full_name';
const String _keyIsLock      = 'is_lock';
const String _keyUserId      = 'user_id';

// ==================== SESSION STORAGE ====================
class SessionStorage {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> saveSession({
    required String accessToken,
    required String role,
    required String fullName,
    required bool isLock,
    required int userId,
  }) async {
    final prefs = await _instance;
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRole,        role);
    await prefs.setString(_keyFullName,    fullName);
    await prefs.setBool(_keyIsLock,        isLock);
    await prefs.setInt(_keyUserId,         userId);
  }

  static Future<String?> getAccessToken() async =>
      (await _instance).getString(_keyAccessToken);
  static Future<String?> getRole() async =>
      (await _instance).getString(_keyRole);
  static Future<String?> getFullName() async =>
      (await _instance).getString(_keyFullName);
  static Future<bool>    getIsLock() async =>
      (await _instance).getBool(_keyIsLock) ?? false;
  static Future<int?>    getUserId() async =>
      (await _instance).getInt(_keyUserId);

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyIsLock);
    await prefs.remove(_keyUserId);
  }
}

// ==================== API RESPONSE MODEL ====================
class ApiResult<T> {
  final int code;
  final T? data;
  final String message;
  int? statusCode; // ← THÊM FIELD NÀY để lưu HTTP status
  bool isSuccess;  // ← KHÔNG final nữa, để có thể set sau

  ApiResult({
    required this.code,
    this.data,
    required this.message,
    this.statusCode,
    this.isSuccess = false, // mặc định false, sẽ set sau
  });

  factory ApiResult.fromJson(
      Map<String, dynamic> json, T? Function(dynamic)? fromData) {
    return ApiResult(
      code: json['code'] ?? 0,
      data: fromData != null ? fromData(json['data']) : null,
      message: json['message'] ?? '',
    );
  }

  factory ApiResult.localError(String message) =>
      ApiResult(code: 999, message: message);
}

// ==================== HTTP CLIENT ====================
class ApiHelper {
  static String get baseUrl => _baseUrl;

  // ── Headers (JSON) ──
  static Future<Map<String, String>> _buildHeaders(
      {bool requireAuth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };
    if (requireAuth) {
      final token = await SessionStorage.getAccessToken();
      if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── Parse response ──
  static ApiResult<T> _parse<T>(
      http.Response res,
      T? Function(dynamic)? fromData,
      ) {
    final rawBody = utf8.decode(res.bodyBytes, allowMalformed: true);

    try {
      if (rawBody.isEmpty) {
        return ApiResult.localError('Phản hồi từ server rỗng (status ${res.statusCode})')
          ..statusCode = res.statusCode;
      }

      final json = jsonDecode(rawBody);

      if (json is! Map<String, dynamic>) {
        return ApiResult.localError('Dữ liệu trả về không phải object JSON (status ${res.statusCode})')
          ..statusCode = res.statusCode;
      }

      final code = json['code'] as int? ?? (res.statusCode == 200 || res.statusCode == 201 ? 900 : res.statusCode);
      final message = json['message'] as String? ?? 'Lỗi từ server (status ${res.statusCode})';
      final data = json['data'];

      final result = ApiResult<T>(
        code: code,
        data: fromData != null && data != null ? fromData(data) : null,
        message: message,
        statusCode: res.statusCode, // ← LƯU STATUS CODE
      );

      // Set isSuccess dựa trên status code (đây là cách đúng)
      result.isSuccess = res.statusCode == 200 || res.statusCode == 201;

      return result;
    } catch (e, stack) {
      print('Parse error: $e\n$stack');
      return ApiResult.localError('Lỗi phân tích dữ liệu từ server (status ${res.statusCode}): $e')
        ..statusCode = res.statusCode;
    }
  }

  // ════════════════════════════════════════
  // GET
  // ════════════════════════════════════════
  static Future<ApiResult<T>> get<T>(
      String endpoint, {
        bool requireAuth = true,
        T? Function(dynamic)? fromData,
        Map<String, String>? queryParams,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      final res = await http
          .get(uri, headers: await _buildHeaders(requireAuth: requireAuth))
          .timeout(const Duration(seconds: 15));
      return _parse(res, fromData);
    } on SocketException {
      return ApiResult.localError('Không có kết nối mạng');
    } catch (e) {
      return ApiResult.localError('Lỗi kết nối: $e');
    }
  }

  // ════════════════════════════════════════
  // POST
  // ════════════════════════════════════════
  static Future<ApiResult<T>> post<T>(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requireAuth = true,
        T? Function(dynamic)? fromData,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final res = await http
          .post(uri,
          headers: await _buildHeaders(requireAuth: requireAuth),
          body:    jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parse(res, fromData);
    } on SocketException {
      return ApiResult.localError('Không có kết nối mạng');
    } catch (e) {
      return ApiResult.localError('Lỗi kết nối: $e');
    }
  }

  // ════════════════════════════════════════
  // PUT
  // ════════════════════════════════════════
  static Future<ApiResult<T>> put<T>(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requireAuth = true,
        T? Function(dynamic)? fromData,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final res = await http
          .put(uri,
          headers: await _buildHeaders(requireAuth: requireAuth),
          body:    jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parse(res, fromData);
    } on SocketException {
      return ApiResult.localError('Không có kết nối mạng');
    } catch (e) {
      return ApiResult.localError('Lỗi kết nối: $e');
    }
  }

  // ════════════════════════════════════════
  // DELETE
  // ════════════════════════════════════════
  static Future<ApiResult<T>> delete<T>(
      String endpoint, {
        bool requireAuth = true,
        T? Function(dynamic)? fromData,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final res = await http
          .delete(uri, headers: await _buildHeaders(requireAuth: requireAuth))
          .timeout(const Duration(seconds: 15));
      return _parse(res, fromData);
    } on SocketException {
      return ApiResult.localError('Không có kết nối mạng');
    } catch (e) {
      return ApiResult.localError('Lỗi kết nối: $e');
    }
  }

  // ════════════════════════════════════════
  // UPLOAD FILE (multipart/form-data)
  // ════════════════════════════════════════
  static Future<ApiResult<T>> uploadFile<T>(
      String endpoint, {
        required String filePath,
        String fieldName = 'image',
        bool requireAuth = true,
        T? Function(dynamic)? fromData,
      }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final token = requireAuth ? await SessionStorage.getAccessToken() : null;

      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json';

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final multipartFile = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(multipartFile);

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);

      return _parse(res, fromData);
    } catch (e, stack) {
      return ApiResult.localError('Lỗi upload: $e');
    }
  }
}

bool isDeveloperAccount(String? username) {
  if (username == null) return false;
  final lower = username.toLowerCase().trim();
  return lower.startsWith('developer') &&
      RegExp(r'developer[1-9]$').hasMatch(lower);
}

// ==================== ERROR MESSAGE HELPER ====================
String getErrorMessage(int code, String serverMessage) {
  switch (code) {
    case 901: return 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại';
    case 902: return 'Bạn không có quyền thực hiện thao tác này';
    case 903: return 'Dữ liệu không hợp lệ, vui lòng kiểm tra lại';
    case 904: return 'Không tìm thấy dữ liệu yêu cầu';
    case 905: return 'Dữ liệu đã tồn tại trong hệ thống';
    case 906: return 'Dữ liệu nhập vào không đúng định dạng';
    case 907: return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
    case 921: return 'Lỗi máy chủ, vui lòng thử lại sau';
    case 922: return 'Hệ thống đang bảo trì, vui lòng thử lại sau';
    case 923: return 'Lỗi cơ sở dữ liệu';
    case 941: return 'Sai mật khẩu, vui lòng kiểm tra lại';
    case 942: return 'Tài khoản của bạn đã bị khóa';
    case 943: return 'Email này đã được đăng ký';
    case 944: return 'Số điện thoại này đã được đăng ký';
    case 945: return 'Số dư tài khoản không đủ';
    case 946: return 'Giao dịch thất bại';
    case 947: return 'Sản phẩm đã hết hàng';
    case 948: return 'Mã OTP không hợp lệ';
    case 949: return 'Mã OTP đã hết hạn';
    case 999: return serverMessage;
    default:
      return serverMessage.isNotEmpty
          ? serverMessage
          : 'Đã có lỗi xảy ra, vui lòng thử lại';
  }
}