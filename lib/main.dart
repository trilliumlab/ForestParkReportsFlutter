import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('forestPark').manage.create();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
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

    return _providers(
      child: _themes(
        builder: (light, dark) => PlatformApp(
          material: (_, __) => MaterialAppData(
            theme: light,
            darkTheme: dark,
            themeMode: ThemeMode.system
          ),
          cupertino: (_, __) => CupertinoAppData(
            theme: CupertinoThemeData(brightness: _brightness)
          ),
          title: 'Forest Park Reports',
          home: const HomeScreen(),
        ),
      ),
    );
  }

  // here we build the apps theme
  Widget _themes({required Widget Function(ThemeData light, ThemeData dark) builder}) {
    // DynamicColorBuilder allows us to get the system theme on android, macos, and windows.
    // On android the colorScheme will be the material you color palette,
    // on macos and windows, this will be derived from the system accent color.
    return Builder(
      builder: (context) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            // In case we can't get a system theme, we need a fallback theme.
            // We are only modifying the colorScheme field of ThemeData,
            // so ONLY USE COLORS FROM THERE!
            // TODO make a proper app theme and move to theme file.
            var light = ThemeData(
              colorScheme: lightDynamic,
              brightness: Brightness.light,
              useMaterial3: true,
            );
            var dark = ThemeData(
              colorScheme: darkDynamic,
              brightness: Brightness.dark,
              useMaterial3: true,
            );
            if (isCupertino(context)) {
              light = light.copyWith(colorScheme: light.colorScheme.copyWith(
                surface: Colors.grey.shade100,
                onSurface: Colors.grey.shade800,
              ));
              dark = dark.copyWith(colorScheme: dark.colorScheme.copyWith(
                surface: Colors.grey.shade900,
                onSurface: Colors.grey.shade100,
              ));
            }
            return Theme(
              data: _brightness == Brightness.dark ? dark : light,
              child: builder(light, dark),
            );
          },
        );
      }
    );
  }

  // here we define all of apps provider widgets
  Widget _providers({required Widget child}) {
    // ProviderScope is Riverpod's provider, used for state management
    return ProviderScope(
      // PlatformProvider is flutter_platform_widgets' provider, allowing us
      // to use widgets that render in the style of the device's platform.
      // Eg. cupertino on ios, and material 3 on android
      child: PlatformProvider(
        initialPlatform: kPlatformOverride,
        builder: (context) {
          return child;
        },
      ),
    );
  }
}
