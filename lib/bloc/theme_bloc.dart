import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:movie_catalog/services/theme_service.dart';
import 'package:rxdart/rxdart.dart';

class ThemeBloc extends BlocBase {
  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the boolean if dark mode is enabled or not
  BehaviorSubject<bool> _changeThemeController = new BehaviorSubject();

  /// The [Sink] is the input for the [_changeThemeController]
  Sink<bool> get changeTheme => _changeThemeController.sink;

  /// The [Stream] is the output for the [_changeThemeController]
  Stream<bool> get darkThemeEnabled => _changeThemeController.stream;

  final ThemeService _themeService = new ThemeService();

  bool _darkModeEnabled = true;

  ThemeBloc() {
    getThemeMode();
    _changeThemeController.stream.listen(_handleChangeTheme);
  }

  void getThemeMode() async {
    _darkModeEnabled = await _themeService.readFile();
    print('This is what I got from the file reader $_darkModeEnabled');
    changeTheme.add(_darkModeEnabled);
  }

  void _handleChangeTheme(bool event) {
    _darkModeEnabled = event;
    _themeService.writeToFile(_darkModeEnabled);
    print('Ive written $_darkModeEnabled to the file service');
  }

  void dispose() {
    _changeThemeController.close();
  }
}
