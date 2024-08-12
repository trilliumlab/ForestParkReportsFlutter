import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:forest_park_reports/util/offline_uploader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/page/home_page.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final providerContainer = ProviderContainer();
final GlobalKey homeKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize in parallel
  await Future.wait([
    dotenv.load(),
    // Run consecutively.
    () async {
      await FMTCObjectBoxBackend().initialise();
      await const FMTCStore('forestPark').manage.create();
    }(),
    OfflineUploader().initialize()
  ]);

  runApp(UncontrolledProviderScope(
    container: providerContainer,
    child: const App(),
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
  // ignore: unused_field
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
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp
      ]
    );
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
      initialPlatform: kDebugMode ? kPlatformOverride : null,
      builder: (context) {
        return _theme(
          builder: (context) => PlatformApp(
            title: 'Forest Park Reports',
            home: HomeScreen(key: homeKey),
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
    final materialLightTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kMaterialAppPrimaryColor,
        brightness: Brightness.light,
      )
    );
    final materialDarkTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kMaterialAppPrimaryColor,
        brightness: Brightness.dark,
      )
    );

    // Cupertino themes
    final lightDefaultCupertinoTheme = CupertinoThemeData(brightness: Brightness.light, primaryColor: kCupertinoAppPrimaryColor);
    final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialLightTheme.copyWith(
        cupertinoOverrideTheme:  CupertinoThemeData(
          brightness: Brightness.light,
          barBackgroundColor: lightDefaultCupertinoTheme.barBackgroundColor,
          primaryColor: kCupertinoAppPrimaryColor,
          textTheme: CupertinoTextThemeData(
            navActionTextStyle: lightDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(color: kCupertinoAppPrimaryColor)
          ),
        ),
      ),
    );
    final darkDefaultCupertinoTheme = CupertinoThemeData(brightness: Brightness.dark, primaryColor: kCupertinoAppPrimaryColor);
    final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialDarkTheme.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: kCupertinoAppPrimaryColor,
          barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
          textTheme: CupertinoTextThemeData(
              navActionTextStyle: darkDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(color: kCupertinoAppPrimaryColor)
          ),
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
  }
}
