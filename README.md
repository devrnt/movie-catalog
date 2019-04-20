# Movie catalog

🎬 Browse through movies from the YIFY api

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Todo
* Add tests
* Sentry

### Done this version
* Watch poster fullscreen
* Fix bug when user starts with no internet that no movies get fetched after internet available
* Firebase message opens play store
* Add info from external sources like themoviedb.com (cast)

## Building
To build the **free** version: 
```
flutter build apk --release --flavor free -t lib/main.dart
```

To build the **pro** version
```dart
flutter build apk --release --flavor pro -t lib/main_pro.dart
```

**Explanation:** The `flavor` option makes sure that in Android the `build.gradle` is using the right build flavors (including different applicationId).
The `target` option (-t) makes sure we can use the different flavors in the dart code.

## Play Store
### Free
[https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog](https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog)
### Pro
[https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog.pro](https://play.google.com/store/apps/details?id=com.devrnt.moviecatalog.pro)
