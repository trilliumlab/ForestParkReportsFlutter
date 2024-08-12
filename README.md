<!-- Title + Logo -->
<br />
<div align="center">

  # Trail Eyes App

  <img src="assets/icon/icon.png" alt="Logo" width="80" height="80">

  A hazard-tracking app for Forest Park, Portland.

  Development sponsored by Portland State University and NSF award CIF-2046175.


  [![Release][release-shield]][release-url]
  [![Build Status][actions-shield]][actions-url]
  [![Last Commit][last-commit-shield]][last-commit-url]
  [![License][license-shield]][license-url]
</div>

## Downloads

Nightly builds are available through CI from the [actions tab][actions-url].
App Store/Play Store builds are not available yet.

The latest nightly builds can be found here:

[![Android][apk-shield]][apk-url]
[![iOS][ipa-shield]][ipa-url]

> [!WARNING]  
> Nightly builds are **experimental** and **untested**.
> Builds are distributing for testing purposes only, and may not be stable.

<!-- [![Play Store][play-store-shield]][play-store-url]
[![iOS][app-store-shield]][app-store-url] -->

## About

Trail Eyes is developed in Flutter.
For more information, see the [online documentation][flutter-docs-url].

## How to Build

### Required

- [Flutter][flutter-dep-url] >= `3.0.0`
- [Xcode][xcode-dep-url] (optional; only required for iOS/MacOS builds)

### Installation

1. Clone this project: 
   ```bash
   git clone https://github.com/trilliumlab/forest-park-reports-app.git
   ```

2. Most work happens on the dev branch. To switch to the dev branch:
   ```bash
   git checkout dev
   ```

3. Fetch project dependencies:
   ```bash
   flutter pub get
   ```

4. Create a `.env` file in the project root. This step is required, but adding a mapbox api key is optional.
   ```dotenv 
   MAPBOX_KEY=API_KEY_HERE
   ```

### Running

1. Run code generation:
   
   ```bash
   dart run build_runner build
   ```

> [!IMPORTANT]  
> Code generation needs to be run whenever files in [lib/model](lib/model) and [lib/provider](lib/provider)
> are modified.
> To have code generation automatically run on save, run `dart run build_runner watch`

2. Now your can run Trail Eyes:

   ```bash
   flutter run
   ```
  
> [!NOTE]  
> iOS development requires some extra setup. To configure a signing certificate,
> open [ios/Runner.xcworkspace](ios/Runner.xcworkspace) in Xcode. 
> Ensure you're signed into your development Apple ID, and select `Runner` in the sidebar.
> Under `Signing & Capabilities`, select `Automatically manage signing`,
> and select your team under the `Team` dropdown.

### Building

- To build an APK for android:

  ```bash
  flutter build --release apk
  ```

- To build an IPA for iOS:

  ```bash
  flutter build --release ipa
  ```

> [!NOTE]  
> The export options must be configured in Xcode manually after the first run.
> Open [build/ios/archive/Runner.xcarchive](build/ios/archive/Runner.xcarchive)
> in Xcode and distribute the IPA.
> This will produce an `ExportOptions.plist` that can be used to automatically build IPAs with the
> same settings in the future. To pass the `ExportOptions.plist` to flutter, append `--export-options-plist=path/to/ExportOptions.plist` to the previous command.

## Project Structure

```ini
forest-park-reports-app
├── android # native Android project
├── assets # app assets
│   ├── icon # Trail Eyes icon
│   └── markers # trail start/end marker
├── ios # native iOS project
├── lib # flutter code src directory
│   ├── model # data models - uses freezed and json_serializable for codegen
│   ├── page # holds pages and widgets
│   │   ├── common # widgets reusable across all pages
│   │   ├── home_page # widgets specific to home_page
│   │   │   ├── map_page # widgets specific to map_page
│   │   │   └── panel_page # widgets specific to panel_page
│   │   └── settings_page # widgets specific to settings_page
│   ├── provider # riverpod providers - all state management should be here
│   └── util # utility/extension functions
├── linux # native Linux project
├── macos # native MacOS project
├── web # native web project
└── windows # native Windows projecct
```

## Assets

The [assets/icon](assets/icon) folder contains the app icon. This was created in Adobe Illustrator
and the source files are [icon 3d.ai](assets/icon/icon 3d.ai) for the main icon and
[icon.ai](assets/icon/icon.ai) for a flat version. [icon.png](assets/icon/icon.png) is the full
rendered icon, and [background.png](assets/icon/background.png) and
[foreground.png](assets/icon/foreground.png) are separated bg/fg layers
(used by android adaptive icons).

Custom icon symbols go in the [assets/icons](assets/svg_icons) directory (svgs only). The icons are
loaded in flutter using a font file. To generate the font file and the dart icon class, run:

```bash
dart run icon_font_generator:generator
```

## Contributing

Contributions are welcomed! If you have any suggestions, feel free to open a pull request.

1. Fork the project.
2. Create a new branch `git checkout -b feature/new-feature-name`
3. Commit your changes `git commit -m 'Added new feature`
4. Push your changes `git push`
5. Open a [pull request][pr-url].

Not up for a pull request? Feel free to open an [issue][issues-url].

## License

Trail Eyes is provided under the MIT license. See [LICENSE.md](LICENSE.md)

<!-- Repository Links -->
[pr-url]: https://github.com/trilliumlab/forest-park-reports-app/pulls
[issues-url]: https://github.com/trilliumlab/forest-park-reports-app/issues

<!-- Status Links -->
[release-url]: https://github.com/trilliumlab/forest-park-reports-app/releases
[release-shield]: https://img.shields.io/github/v/release/trilliumlab/forest-park-reports-app?include_prereleases&style=for-the-badge
[actions-url]: https://github.com/trilliumlab/forest-park-reports-app/actions/workflows/flutter.yml
[actions-shield]: https://img.shields.io/github/actions/workflow/status/trilliumlab/forest-park-reports-app/flutter.yml?style=for-the-badge
[last-commit-url]: https://github.com/trilliumlab/forest-park-reports-app/commits/dev/
[last-commit-shield]: https://img.shields.io/github/last-commit/trilliumlab/forest-park-reports-app/dev?style=for-the-badge
[license-url]: LICENSE.md
[license-shield]: https://img.shields.io/github/license/trilliumlab/forest-park-reports-app?style=for-the-badge

<!-- Download Links -->
[apk-url]: https://nightly.link/trilliumlab/forest-park-reports-app/workflows/flutter/dev/forest_park_reports.apk.zip
[apk-shield]: https://img.shields.io/badge/APK-3DDC84?style=for-the-badge&logo=android&logoColor=white
[ipa-url]: https://nightly.link/trilliumlab/forest-park-reports-app/workflows/flutter/dev/forest_park_reports.ipa.zip
[ipa-shield]: https://img.shields.io/badge/IPA-000000?style=for-the-badge&logo=ios&logoColor=white

<!-- Store Links -->
[play-store-url]: none
[play-store-shield]: https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white
[app-store-url]: none
[app-store-shield]: https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white

<!-- Dependency links -->
[flutter-dep-url]: https://flutter.dev/
[xcode-dep-url]: https://developer.apple.com/xcode/

<!-- Docs links -->
[flutter-docs-url]: https://docs.flutter.dev/
