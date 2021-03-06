import 'package:movie_catalog/blocs/bloc_base.dart';
import 'package:movie_catalog/services/storage/theme_service.dart';
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
    changeTheme.add(_darkModeEnabled);
  }

  void _handleChangeTheme(bool flag) async {
    _darkModeEnabled = flag;
    await _themeService.writeToFile(_darkModeEnabled);
  }

  void dispose() {
    _changeThemeController.close();
  }
}
