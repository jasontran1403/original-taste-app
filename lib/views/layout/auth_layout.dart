import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/layout/auth_layout_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_responsiv.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/images.dart';

class AuthLayout extends StatefulWidget {
  final Widget? child;

  const AuthLayout({super.key, this.child});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _scrollKey = GlobalKey();

  late final AuthLayoutController controller;

  @override
  void initState() {
    super.initState();
    controller = AuthLayoutController();
  }

  @override
  Widget build(BuildContext context) {
    return MyResponsive(
      builder: (BuildContext context, _, screenMT) {
        return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile ? mobileScreen(context) : largeScreen(context);
          },
        );
      },
    );
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: MyContainer(
        padding: MySpacing.all(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        color: theme.cardTheme.color,
        child: SingleChildScrollView(key: _scrollKey, child: widget.child),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        color: const Color(0xFFf9f7f7),
        padding: MySpacing.all(20),
        child: MyFlex(
          runAlignment: WrapAlignment.center,
          wrapCrossAlignment: WrapCrossAlignment.center,
          wrapAlignment: WrapAlignment.center,
          contentPadding: false,
          children: [
            MyFlexItem(
              sizes: 'lg-7 md-6',
              child: MyFlex(
                contentPadding: false,
                runAlignment: WrapAlignment.center,
                wrapCrossAlignment: WrapCrossAlignment.center,
                wrapAlignment: WrapAlignment.center,
                children: [
                  MyFlexItem(sizes: 'lg-6', child: widget.child ?? const SizedBox()),
                ],
              ),
            ),
            MyFlexItem(sizes: 'lg-5 md-6', child: buildCard()),
          ],
        ),
      ),
    );
  }

  Widget buildCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    final double containerHeight = screenHeight / 1.04;

    return MyContainer(
      height: containerHeight,
      borderRadiusAll: 14,
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(Images.smallImages[9], fit: BoxFit.fill),
    );
  }
}