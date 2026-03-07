// lib/controller/ui/general/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/api_helper.dart';
import 'package:original_taste/helper/services/dashboard_services.dart';

// ══════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════

enum DashboardMode { pos, wholesale, retail }

enum DashboardPeriod {
  today('TODAY',   'Hôm nay'),
  days7('7DAYS',   '7 ngày'),
  days30('30DAYS', '30 ngày'),
  year('YEAR',     '1 năm'),
  custom('CUSTOM', 'Tuỳ chọn');

  final String apiValue;
  final String label;
  const DashboardPeriod(this.apiValue, this.label);
}

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class DashboardController extends MyController {
  // ── UI State ───────────────────────────────────────────────────
  DashboardMode   mode   = DashboardMode.pos;
  DashboardPeriod period = DashboardPeriod.days30;
  DateTime?       customFrom;
  DateTime?       customTo;

  final RxDouble ramUsagePercent = 0.0.obs;
  final RxInt lastQueryDurationMs = 0.obs;

  // ── Reload key ─────────────────────────────────────────────────
  int reloadKey = 0;

  // ── Restaurant data (wholesale / retail) ───────────────────────
  bool                      isLoading = false;
  String                    errorMsg  = '';
  RestaurantDashboardModel? data;

  // ── POS data ───────────────────────────────────────────────────
  bool               posIsLoading    = false;
  String             posErrorMsg     = '';
  PosDashboardModel? posData;
  int                posAnimationKey = 0;

  // Cache để phát hiện thay đổi cho POS
  DashboardPeriod _posLastPeriod     = DashboardPeriod.days30;
  DateTime?       _posLastCustomFrom;
  DateTime?       _posLastCustomTo;
  int             _posLastReloadKey  = -1;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // ══════════════════════════════════════════════════════════════
  // PUBLIC ACTIONS
  // ══════════════════════════════════════════════════════════════

  Future<void> reload() => load();

  void pullRefresh() {
    reloadKey++;
    load();
  }

  void setMode(DashboardMode m) {
    if (mode == m) return;
    mode = m;
    load();
  }

  void setPeriod(DashboardPeriod p, {DateTime? from, DateTime? to}) {
    period     = p;
    customFrom = from;
    customTo   = to;
    reloadKey++;
    load();
  }

  /// Gọi từ PosDashboardScreen — chỉ re-fetch khi thực sự có thay đổi
  Future<void> syncPosIfNeeded() async {
    final changed = reloadKey  != _posLastReloadKey  ||
        period     != _posLastPeriod     ||
        customFrom != _posLastCustomFrom ||
        customTo   != _posLastCustomTo;
    if (changed) await _loadPos();
  }

  // ══════════════════════════════════════════════════════════════
  // LOAD — điều phối theo mode
  // ══════════════════════════════════════════════════════════════

  Future<void> load() async {
    if (mode == DashboardMode.pos) {
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

    posIsLoading = true;
    posErrorMsg  = '';
    update();

    try {
      final result = await PosDashboardService.getPosDashboard(
        period:   period,
        fromDate: customFrom,
        toDate:   customTo,
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
    update();

    try {
      final result = await DashboardService.getRestaurantDashboard(
        period:   period,
        fromDate: customFrom,
        toDate:   customTo,
        mode:     mode.name,  // "wholesale" hoặc "retail"
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
  // CONVENIENT GETTERS
  // ══════════════════════════════════════════════════════════════

  bool get hasData    => data    != null && !isLoading    && errorMsg.isEmpty;
  bool get hasPosData => posData != null && !posIsLoading && posErrorMsg.isEmpty;
}