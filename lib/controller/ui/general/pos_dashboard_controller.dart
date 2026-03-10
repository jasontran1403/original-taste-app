// lib/controller/ui/general/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/api_helper.dart';

import '../../../helper/services/pos_dashboard_services.dart';

// ══════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════

enum PosDashboardMode { pos }

enum PosDashboardPeriod {
  today('TODAY',   'Hôm nay'),
  days7('7DAYS',   '7 ngày'),
  days30('30DAYS', '30 ngày'),
  year('YEAR',     '1 năm'),
  custom('CUSTOM', 'Tuỳ chọn');

  final String apiValue;
  final String label;
  const PosDashboardPeriod(this.apiValue, this.label);
}

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class PosDashboardController extends MyController {
  // ── UI State ───────────────────────────────────────────────────
  PosDashboardMode   mode   = PosDashboardMode.pos;
  PosDashboardPeriod period = PosDashboardPeriod.days30;
  DateTime?       customFrom;
  DateTime?       customTo;

  final RxDouble ramUsagePercent = 0.0.obs;
  final RxInt lastQueryDurationMs = 0.obs;

  // ── Reload key ─────────────────────────────────────────────────
  int reloadKey = 0;


  // ── POS data ───────────────────────────────────────────────────
  bool               posIsLoading    = false;
  String             posErrorMsg     = '';
  PosAdminDashboardModel? posData;
  int                posAnimationKey = 0;

  // Cache để phát hiện thay đổi cho POS
  PosDashboardPeriod _posLastPeriod     = PosDashboardPeriod.days30;
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

  void setMode(PosDashboardMode m) {
    if (mode == m) return;
    mode = m;
    load();
  }

  void setPeriod(PosDashboardPeriod p, {DateTime? from, DateTime? to}) {
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
    if (mode == PosDashboardMode.pos) {
      await _loadPos();
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
      final result = await PosAdminDashboardService.getPosDashboard(
        period:   period,
        fromDate: customFrom,
        toDate:   customTo,
      );

      print(result);

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


  // ══════════════════════════════════════════════════════════════
  // CONVENIENT GETTERS
  // ══════════════════════════════════════════════════════════════
  bool get hasPosData => posData != null && !posIsLoading && posErrorMsg.isEmpty;
}