import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:original_taste/helper/extensions/app_localization_delegate.dart';
import 'package:original_taste/helper/services/localization/language.dart';
import 'package:original_taste/helper/services/navigation_service.dart';
import 'package:original_taste/helper/services/storage/local_storage.dart';
import 'package:original_taste/helper/theme/app_notifier.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/routes.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:original_taste/helper/theme/app_style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  runApp(ChangeNotifierProvider<AppNotifier>(create: (context) => AppNotifier(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: "/auth/sign_in",
          getPages: getPageRoute(),
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(textDirection: AppTheme.textDirection, child: child ?? Container());
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
