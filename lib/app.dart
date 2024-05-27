import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/l10n/gen/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:toolbox/data/res/build_data.dart';
import 'package:toolbox/data/res/rebuild.dart';
import 'package:toolbox/data/res/store.dart';
import 'package:toolbox/view/page/home/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setup(context);
    return ListenableBuilder(
      listenable: RebuildNodes.app,
      builder: (context, _) {
        if (!Stores.setting.useSystemPrimaryColor.fetch()) {
          UIs.colorSeed = Color(Stores.setting.primaryColor.fetch());
          return _buildApp(context);
        }
        return DynamicColorBuilder(
          builder: (light, dark) {
            final lightTheme = ThemeData(
              useMaterial3: true,
              colorScheme: light,
            );
            final darkTheme = ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: dark,
            );
            if (context.isDark && light != null) {
              UIs.primaryColor = light.primary;
            } else if (!context.isDark && dark != null) {
              UIs.primaryColor = dark.primary;
            }
            return _buildApp(context, light: lightTheme, dark: darkTheme);
          },
        );
      },
    );
  }

  Widget _buildApp(BuildContext ctx, {ThemeData? light, ThemeData? dark}) {
    final tMode = Stores.setting.themeMode.fetch();
    // Issue #57
    final themeMode = switch (tMode) {
      1 || 2 => ThemeMode.values[tMode],
      3 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final locale = Stores.setting.locale.fetch().toLocale;

    light ??= ThemeData(
      useMaterial3: true,
      colorSchemeSeed: UIs.colorSeed,
    );
    dark ??= ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: UIs.colorSeed,
    );

    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        LibLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: BuildData.name,
      themeMode: themeMode,
      theme: light,
      darkTheme: tMode < 3 ? dark : _getAmoledTheme(dark),
      home: _buildAppContent(ctx),
    );
  }

  Widget _buildAppContent(BuildContext ctx) {
    //if (Pros.app.isWearOS) return const WearHome();
    return const HomePage();
  }
}

void _setup(BuildContext context) async {
  SystemUIs.setTransparentNavigationBar(context);
}

ThemeData _getAmoledTheme(ThemeData darkTheme) => darkTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      dialogBackgroundColor: Colors.black,
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      dialogTheme: const DialogTheme(backgroundColor: Colors.black),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: Colors.black),
      listTileTheme: const ListTileThemeData(tileColor: Colors.transparent),
      cardTheme: const CardTheme(color: Colors.black12),
      navigationBarTheme:
          const NavigationBarThemeData(backgroundColor: Colors.black),
      popupMenuTheme: const PopupMenuThemeData(color: Colors.black),
    );
