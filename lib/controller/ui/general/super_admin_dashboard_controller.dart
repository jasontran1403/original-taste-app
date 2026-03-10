// lib/controller/ui/general/super_admin_dashboard_controller.dart

import 'dart:async';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/api_helper.dart';
import '../../../helper/services/super_admin_dashboard_services.dart';

// ══════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════

enum SuperAdminDashboardMode { pos, wholesale, retail }

enum SuperAdminDashboardPeriod {
  today('TODAY',   'Hôm nay'),
  days7('7DAYS',   '7 ngày'),
  days30('30DAYS', '30 ngày'),
  year('YEAR',     '1 năm'),
  custom('CUSTOM', 'Tuỳ chọn');

  final String apiValue;
  final String label;
  const SuperAdminDashboardPeriod(this.apiValue, this.label);
}

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class SuperAdminDashboardController extends MyController {
  // ── UI State ───────────────────────────────────────────────────
  SuperAdminDashboardMode   mode   = SuperAdminDashboardMode.pos;
  SuperAdminDashboardPeriod period = SuperAdminDashboardPeriod.days30;
  DateTime?                 customFrom;
  DateTime?                 customTo;

  // ── Reload key ─────────────────────────────────────────────────
  int reloadKey = 0;

  // ── Restaurant data (wholesale / retail) ───────────────────────
  bool                                isLoading = false;
  String                              errorMsg  = '';
  SuperAdminRestaurantDashboardModel? data;

  // ── POS data ───────────────────────────────────────────────────
  bool                         posIsLoading    = false;
  String                       posErrorMsg     = '';
  SuperAdminPosDashboardModel? posData;
  int                          posAnimationKey = 0;

  // ── Vehicle (POS) ──────────────────────────────────────────────
  bool              vehiclesLoading = false;
  String            vehiclesError   = '';
  List<PosVehicle>  vehicles        = [];
  PosVehicle?       selectedVehicle;

  /// Danh sách xe đã filter theo query
  List<PosVehicle>  filteredVehicles = [];
  String            vehicleQuery     = '';
  Timer?            _vehicleDebounce;

  // Cache để phát hiện thay đổi cho POS
  SuperAdminDashboardPeriod _posLastPeriod     = SuperAdminDashboardPeriod.days30;
  DateTime?                 _posLastCustomFrom;
  DateTime?                 _posLastCustomTo;
  int                       _posLastReloadKey  = -1;
  int?                      _posLastVehicleId;   // ← NEW

  @override
  void onInit() {
    super.onInit();
    _loadVehicles(); // load xe trước, sau đó load POS data
  }

  @override
  void onClose() {
    _vehicleDebounce?.cancel();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════
  // VEHICLE ACTIONS
  // ══════════════════════════════════════════════════════════════

  Future<void> _loadVehicles() async {
    vehiclesLoading = true;
    vehiclesError   = '';
    update();

    try {
      final result = await SuperAdminDashboardService.getVehicles();

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        vehicles         = result.data!;
        filteredVehicles = vehicles;
        selectedVehicle  = vehicles.first; // mặc định chọn xe đầu tiên
      } else {
        vehiclesError = getErrorMessage(result.code, result.message);
      }
    } catch (e) {
      vehiclesError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      vehiclesLoading = false;
      update();
    }

    // Load POS data sau khi có xe
    await _loadPos();
  }

  void selectVehicle(PosVehicle v) {
    if (selectedVehicle?.id == v.id) return;
    selectedVehicle = v;
    vehicleQuery    = '';
    filteredVehicles = vehicles;
    reloadKey++;
    update();
    _loadPos();
  }

  /// Debounce 900ms — gọi khi user gõ vào search box
  void onVehicleSearchChanged(String query) {
    vehicleQuery = query;
    _vehicleDebounce?.cancel();
    // Hiện spinner ngay
    update();
    _vehicleDebounce = Timer(const Duration(milliseconds: 900), () {
      final q = query.trim().toLowerCase();
      filteredVehicles = q.isEmpty
          ? vehicles
          : vehicles.where((v) => v.name.toLowerCase().contains(q)).toList();
      update();
    });
  }

  /// True khi đang đợi debounce (spinner)
  bool get vehicleSearching =>
      _vehicleDebounce?.isActive == true && vehicleQuery.isNotEmpty;

  // ══════════════════════════════════════════════════════════════
  // PUBLIC ACTIONS
  // ══════════════════════════════════════════════════════════════

  Future<void> reload() => load();

  void pullRefresh() {
    reloadKey++;
    load();
  }

  /// Toggle mode POS / Sỉ / Lẻ — gọi update() ngay để toggle re-render
  void setMode(SuperAdminDashboardMode m) {
    if (mode == m) return;
    mode = m;
    update(); // ← re-render ngay, toggle hiển thị đúng tab active
    load();
  }

  void setPeriod(SuperAdminDashboardPeriod p, {DateTime? from, DateTime? to}) {
    period     = p;
    customFrom = from;
    customTo   = to;
    reloadKey++;
    load();
  }

  /// Gọi từ SuperAdminPosDashboardScreen mỗi frame — chỉ fetch khi thực sự thay đổi
  Future<void> syncPosIfNeeded() async {
    final changed = reloadKey          != _posLastReloadKey  ||
        period             != _posLastPeriod     ||
        customFrom         != _posLastCustomFrom ||
        customTo           != _posLastCustomTo   ||
        selectedVehicle?.id != _posLastVehicleId; // ← NEW
    if (changed) await _loadPos();
  }

  // ══════════════════════════════════════════════════════════════
  // LOAD — điều phối theo mode
  // ══════════════════════════════════════════════════════════════

  Future<void> load() async {
    if (mode == SuperAdminDashboardMode.pos) {
      await _loadPos();
    } else {
      await _loadRestaurant();
    }
  }

  // ── POS fetch ─────────────────────────────────────────────────

  Future<void> _loadPos() async {
    _posLastReloadKey  = reloadKey;
    _posLastPeriod     = period;
    _posLastCustomFrom = customFrom;
    _posLastCustomTo   = customTo;
    _posLastVehicleId  = selectedVehicle?.id;  // ← NEW

    posIsLoading = true;
    posErrorMsg  = '';
    update();

    try {
      final result = await SuperAdminDashboardService.getPosDashboard(
        period:    period,
        fromDate:  customFrom,
        toDate:    customTo,
        vehicleId: selectedVehicle?.id,
      );
      if (result.isSuccess && result.data != null) {
        posData         = result.data;
        posAnimationKey++;
      } else {
        posErrorMsg = getErrorMessage(result.code, result.message);
      }
    } catch (e) {
      posErrorMsg = e.toString().replaceFirst('Exception: ', '');
    } finally {
      posIsLoading = false;
      update();
    }
  }

  // ── Restaurant fetch (wholesale / retail) ─────────────────────

  Future<void> _loadRestaurant() async {
    isLoading = true;
    errorMsg  = '';
    data      = null;
    update();

    try {
      final result = await SuperAdminDashboardService.getRestaurantDashboard(
        period:   period,
        fromDate: customFrom,
        toDate:   customTo,
        mode:     mode.name, // "wholesale" hoặc "retail"
      );
      if (result.isSuccess && result.data != null) {
        data = result.data;
      } else {
        errorMsg = getErrorMessage(result.code, result.message);
      }
    } catch (e) {
      errorMsg = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════

  bool get hasData    => data    != null && !isLoading    && errorMsg.isEmpty;
  bool get hasPosData => posData != null && !posIsLoading && posErrorMsg.isEmpty;
}