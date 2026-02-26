import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/widgets/my_breadcrumb_item.dart';
import 'package:original_taste/helper/widgets/my_constant.dart';
import 'package:original_taste/helper/widgets/my_responsiv.dart';
import 'package:original_taste/helper/widgets/my_router.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

class MyBreadcrumb extends StatelessWidget {
  final List<MyBreadcrumbItem> children;
  final bool hideOnMobile;

  MyBreadcrumb({super.key, required this.children, this.hideOnMobile = true}) {
    if (MyConstant.constant.defaultBreadCrumbItem != null) {
      children.insert(0, MyConstant.constant.defaultBreadCrumbItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < children.length; i++) {
      var item = children[i];
      if (item.active || item.route == null) {
        list.add(MyText.labelMedium(
          children[i].name,
          fontWeight: 500,
          fontSize: 13,
          letterSpacing: 0,
        ));
      } else {
        list.add(InkWell(
            onTap: () => {
                  if (item.route != null)
                    MyRouter.pushReplacementNamed(context, item.route!)
                },
            child: MyText.labelMedium(
              children[i].name,
              fontWeight: 500,
              fontSize: 13,
              letterSpacing: 0,
              color: theme.colorScheme.primary,
            )));
      }
      if (i < children.length - 1) {
        list.add(MySpacing.width(10));
        list.add(Icon(RemixIcons.arrow_right_s_line, size: 16, color: theme.colorScheme.secondary));
        list.add(MySpacing.width(10));
      }
    }
    return MyResponsive(builder: (_, _, type) {
      return type.isMobile && hideOnMobile
          ? SizedBox()
          : Row(mainAxisSize: MainAxisSize.min, children: list);
    });
  }
}
