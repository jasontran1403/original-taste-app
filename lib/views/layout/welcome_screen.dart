import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/auth_services.dart';

// ─────────────────────────────────────────────────────────────
// WelcomeScreen — hiển thị 2s sau đăng nhập thành công,
// sau đó fadeout và navigate đến màn chính theo role.
// ─────────────────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──
  late AnimationController _entryCtrl;   // logo + text vào
  late AnimationController _pulseCtrl;  // icon nhịp đập
  late AnimationController _exitCtrl;   // fadeout toàn màn

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _pulse;
  late Animation<double> _exitFade;

  late _RoleTheme _theme;

  @override
  void initState() {
    super.initState();

    _theme = _RoleTheme.forRole(AuthService.currentRole ?? '');

    // Entry: 700ms
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    // Pulse: lặp mãi
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Exit: 500ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _start();
  }

  Future<void> _start() async {
    await _entryCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1300));
    await _exitCtrl.forward();
    if (mounted) {
      final role = AuthService.currentRole ?? '';
      Get.offAllNamed(AppRoutes.homeForRole(role));
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _theme.bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _pulseCtrl, _exitCtrl]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitFade.value,
            child: Stack(
              children: [
                // ── Background decorations ──
                ..._buildBgDecorations(size),

                // ── Main content ──
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _pulse,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _theme.accentColor.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _theme.icon,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Welcome text
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              Text(
                                'Xin chào!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _theme.title,
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  _theme.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Loading dots
                      FadeTransition(
                        opacity: _textOpacity,
                        child: _LoadingDots(color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBgDecorations(Size size) {
    return [
      // Circle lớn góc trên phải
      Positioned(
        top: -size.height * 0.1,
        right: -size.width * 0.15,
        child: Container(
          width: size.width * 0.55,
          height: size.width * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      // Circle nhỏ góc dưới trái
      Positioned(
        bottom: -size.height * 0.08,
        left: -size.width * 0.1,
        child: Container(
          width: size.width * 0.45,
          height: size.width * 0.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      // Dot nhỏ accent
      Positioned(
        top: size.height * 0.15,
        left: size.width * 0.1,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
      Positioned(
        bottom: size.height * 0.2,
        right: size.width * 0.12,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.25),
          ),
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Loading dots animation
// ─────────────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final anim = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _ctrls.add(ctrl);
      _anims.add(anim);
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_ctrls),
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Role theme config
// ─────────────────────────────────────────────────────────────
class _RoleTheme {
  final Color bgColor;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const _RoleTheme({
    required this.bgColor,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static _RoleTheme forRole(String role) {
    switch (role) {
      case AppRole.admin:
        return _RoleTheme(
          bgColor: const Color(0xFF1A1A2E),
          accentColor: const Color(0xFF6C63FF),
          icon: Icons.admin_panel_settings_rounded,
          title: 'Admin Dashboard',
          subtitle: 'QUẢN TRỊ HỆ THỐNG',
        );
      case AppRole.pos:
        return _RoleTheme(
          bgColor: const Color(0xFFE65100),
          accentColor: const Color(0xFFFF8A65),
          icon: Icons.point_of_sale_rounded,
          title: 'POS Bán Hàng',
          subtitle: 'ĐIỂM BÁN HÀNG',
        );
      case AppRole.seller:
        return _RoleTheme(
          bgColor: const Color(0xFF1B5E20),
          accentColor: const Color(0xFF66BB6A),
          icon: Icons.storefront_rounded,
          title: 'Seller Portal',
          subtitle: 'QUẢN LÝ CỬA HÀNG',
        );
      case AppRole.accountant:
        return _RoleTheme(
          bgColor: const Color(0xFF0D47A1),
          accentColor: const Color(0xFF42A5F5),
          icon: Icons.account_balance_rounded,
          title: 'Kế Toán',
          subtitle: 'QUẢN LÝ TÀI CHÍNH',
        );
      case AppRole.warehouse:
        return _RoleTheme(
          bgColor: const Color(0xFF4A148C),
          accentColor: const Color(0xFFBA68C8),
          icon: Icons.warehouse_rounded,
          title: 'Kho Hàng',
          subtitle: 'QUẢN LÝ KHO',
        );
      case AppRole.shipper:
        return _RoleTheme(
          bgColor: const Color(0xFF006064),
          accentColor: const Color(0xFF4DD0E1),
          icon: Icons.delivery_dining_rounded,
          title: 'Giao Hàng',
          subtitle: 'QUẢN LÝ VẬN CHUYỂN',
        );
      default:
        return _RoleTheme(
          bgColor: const Color(0xFF263238),
          accentColor: const Color(0xFF90A4AE),
          icon: Icons.person_rounded,
          title: 'Chào mừng',
          subtitle: 'ORIGINAL TASTE',
        );
    }
  }
}