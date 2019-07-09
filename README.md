# Movie catalog

🎬 Browse through movies from the YIFY api

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

## Todo
* VPN Support
* Refactor bloc patterns and services
* Add tests

### Done this version
* ...

## Building
Create a `keys.dart` file in the `lib/config/` folder and add the following code snippet in the `keys.dart`:

```dart 
class Keys {
  static String admobAppId = 'your admob app id';
  static String addUnitId = 'your admob add unit id';
  static String theMovieDb = 'your https://www.themoviedb.org api key';
  static String sentryDsn = 'your sentry Dsn';
}
```
### Apk
To build the **free** version:
```console
flutter build apk --release --flavor free -t lib/main.dart
```

To build the **pro** version
```
flutter build apk --release --flavor pro -t lib/main_pro.dart
```

**Explanation:** The `flavor` option makes sure that in Android the `build.gradle` is using the right build flavors (including different applicationId).
The `target` option (-t) makes sure we can use the different flavors in the dart code.

**VSCode:** Go to the debug tab (ctrl + shift + D) and select on top the debug configuration and there will be 2 available options: `Flutter Free` and `Flutter Pro`.
These configurations will build the app with the commands given above.

### App bundles (preferred)
To build the **free** version:
```console
flutter build appbundle --flavor free -t lib/main.dart
```

To build the **pro** version
```
flutter build appbundle --flavor pro -t lib/main_pro.dart
```

## Developping
Don't hesitate to fork this repository and if you are having any questions please contact me.

## Play Store
### Free
[https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog](https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog)
### Pro
[https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog.pro](https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog.pro)
