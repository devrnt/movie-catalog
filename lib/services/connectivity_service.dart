import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final _connectivity = Connectivity();
  final _httpClient = http.Client();

  final _connectivityController = BehaviorSubject<ConnectivityResult>();
  get connectivityStream => _connectivityController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      // Add the current result to the stream but do an extra check
      _connectivityController.add(result);
      // Extra check
      // Use case: when a user is connected to a VPN
      _httpConnectivityCheck();
    });
  }

  Future<ConnectivityResult> checkConnectivity() async {
    return _connectivity.checkConnectivity();
  }

  void _httpConnectivityCheck() async {
    try {
      await _httpClient.read('https://yts.am/api/v2/list_movies.json');
      _connectivityController.add(ConnectivityResult.wifi);
    } on Exception catch (e) {
      print('No internet connection: $e');
    }
  }

  void dispose() {
    _connectivityController.drain();
    _connectivityController.close();
  }
}
