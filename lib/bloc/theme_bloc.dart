import 'package:movie_catalog/bloc/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class ThemeBloc extends BlocBase {
  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the boolean if dark mode is enabled or not
  BehaviorSubject<bool> _changeThemeController = new BehaviorSubject();

  /// The [Sink] is the input for the [_changeThemeController]
  get changeTheme => _changeThemeController.sink.add;

  /// The [Stream] is the output for the [_changeThemeController]
  get darkThemeEnabled => _changeThemeController.stream;

  void dispose() {
    _changeThemeController.close();
  }
}
