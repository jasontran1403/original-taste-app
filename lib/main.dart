// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:original_taste/helper/extensions/app_localization_delegate.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/helper/services/localization/language.dart';
import 'package:original_taste/helper/services/navigation_service.dart';
import 'package:original_taste/helper/services/storage/local_storage.dart';
import 'package:original_taste/helper/theme/app_notifier.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/theme/app_style.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/routes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  runApp(
    ChangeNotifierProvider<AppNotifier>(
      create: (_) => AppNotifier(),
      child: const MyApp(),
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.toString();
    if (msg.contains('RenderChartFadeTransition') ||
        msg.contains('_HighlightModeManager') ||
        msg.contains('deactivated widget')) return;
    FlutterError.presentError(details);
  };
}

// ══════════════════════════════════════════════════════════════════
// MyApp — check version ngay sau khi GetMaterialApp mounted
// ══════════════════════════════════════════════════════════════════

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme:      AppTheme.lightTheme,
          darkTheme:  AppTheme.darkTheme,
          themeMode:  ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: '/auth/sign_in',
          getPages: getPageRoute(),
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(
              textDirection: AppTheme.textDirection,
              child: FocusScope(
                canRequestFocus: true,
                descendantsAreFocusable: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  // ── AppVersionWrapper bọc ngoài toàn bộ app ──
                  child: AppVersionWrapper(child: child ?? Container()),
                ),
              ),
            );
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// AppVersionWrapper
// Bọc ngoài toàn bộ widget tree. Check version 1 lần khi mount.
// Hiển thị dialog force/soft update qua NavigationService.navigatorKey
// nên hoạt động đúng kể cả trên màn hình sign_in.
// ══════════════════════════════════════════════════════════════════

class AppVersionWrapper extends StatefulWidget {
  final Widget child;
  const AppVersionWrapper({super.key, required this.child});

  @override
  State<AppVersionWrapper> createState() => _AppVersionWrapperState();
}

class _AppVersionWrapperState extends State<AppVersionWrapper> {
  @override
  void initState() {
    super.initState();
    // Delay 1 frame để Navigator đã mount, showDialog mới hoạt động
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    final result = await AuthService.checkVersion();

    if (!result.hasUpdate) return;

    // Dùng navigatorKey để show dialog từ bất kỳ đâu trong app
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    await _showUpdateDialog(ctx, result);
  }

  Future<void> _showUpdateDialog(
      BuildContext ctx, AppVersionCheckResult result) async {
    await showDialog(
      context:            ctx,
      useRootNavigator:   true,
      barrierDismissible: !result.updateRequired, // force → không tap ngoài để đóng
      builder: (dialogCtx) => _UpdateDialog(
        result:   result,
        onUpdate: () async {
          final url = Uri.parse(result.downloadUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          // Force update: KHÔNG pop → user bị giữ ở dialog
          // Soft update : pop sau khi mở store
          if (!result.updateRequired && dialogCtx.mounted) {
            Navigator.of(dialogCtx, rootNavigator: true).pop();
          }
        },
        onLater: result.updateRequired
            ? null // Force → không có nút "Để sau"
            : () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ══════════════════════════════════════════════════════════════════
// _UpdateDialog
// ══════════════════════════════════════════════════════════════════

class _UpdateDialog extends StatelessWidget {
  final AppVersionCheckResult result;
  final VoidCallback           onUpdate;
  final VoidCallback?          onLater; // null → không hiện nút "Để sau"

  const _UpdateDialog({
    required this.result,
    required this.onUpdate,
    this.onLater,
  });

  bool get _isForce => result.updateRequired;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isForce, // Force → chặn nút back vật lý
      child: Dialog(
        shape:        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header gradient ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isForce
                      ? [const Color(0xFFE53935), const Color(0xFFEF9A9A)]
                      : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Icon(
                    _isForce
                        ? Icons.system_update_alt_rounded
                        : Icons.new_releases_outlined,
                    size:  34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isForce ? 'Cập nhật bắt buộc' : 'Có phiên bản mới',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (result.latestVersion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Phiên bản ${result.latestVersion}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                ],
              ]),
            ),

            // ── Body ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(children: [
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: Color(0xFF424242)),
                ),
                if (_isForce) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color:        Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bạn cần cập nhật để tiếp tục sử dụng ứng dụng.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700),
                        ),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),

            // ── Actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon:  const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Cập nhật ngay',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isForce
                          ? Colors.red.shade600
                          : const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: onUpdate,
                  ),
                ),
                if (onLater != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onLater,
                      child: const Text('Để sau',
                          style: TextStyle(
                              color:      Color(0xFF757575),
                              fontSize:   14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}