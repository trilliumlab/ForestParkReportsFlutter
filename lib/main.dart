import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/providers/settings_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/pages/home_page.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('forestPark').manage.create();
  runApp(const ProviderScope(
    child: App(),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  // we listen to brightness changes (IE light to dark mode) and
  // rebuild the entire widget tree when it's changed
  Brightness _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = View.of(context).platformDispatcher.platformBrightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    // enable edge to edge mode on android
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // PlatformProvider is flutter_platform_widgets' provider, allowing us
    // to use widgets that render in the style of the device's platform.
    // Eg. cupertino on ios, and material 3 on android
    return PlatformProvider(
      initialPlatform: kPlatformOverride,
      builder: (context) {
        return _theme(
          builder: (context) => const PlatformApp(
            title: 'Forest Park Reports',
            home: HomeScreen(),
          ),
        );
      },
    );
  }

  // here we build the apps theme
  Widget _theme({required Widget Function(BuildContext context) builder}) {
    // DynamicColorBuilder allows us to get the system theme on android, macos, and windows.
    // On android the colorScheme will be the material you color palette,
    // on macos and windows, this will be derived from the system accent color.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // In case we can't get a system theme, we need a fallback theme.
        // Material themes
        final materialLightTheme = ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: lightDynamic,
        );
        final materialDarkTheme = ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: darkDynamic,
        );

        // Cupertino themes
        const lightDefaultCupertinoTheme = CupertinoThemeData(brightness: Brightness.light);
        final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
          materialTheme: materialLightTheme.copyWith(
            cupertinoOverrideTheme:  CupertinoThemeData(
              brightness: Brightness.light,
              barBackgroundColor: lightDefaultCupertinoTheme.barBackgroundColor,
              textTheme: const CupertinoTextThemeData(),
            ),
          ),
        );
        const darkDefaultCupertinoTheme = CupertinoThemeData(brightness: Brightness.dark);
        final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
          materialTheme: materialDarkTheme.copyWith(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
              textTheme: const CupertinoTextThemeData(),
            ),
          ),
        );

        return PlatformTheme(
          themeMode: ref.watch(settingsProvider.select((s) => s.colorTheme)).value,
          materialLightTheme: materialLightTheme,
          materialDarkTheme: materialDarkTheme,
          cupertinoLightTheme: cupertinoLightTheme,
          cupertinoDarkTheme: cupertinoDarkTheme,
          builder: builder,
        );
      },
    );
  }
}
