import 'package:debug_mode/debug_mode.dart';
import 'package:sentry/sentry.dart';

class SentryService {
  static Future<void> reportError(
      SentryClient sentryClient, dynamic error, dynamic stackTrace) async {
    // Print the exception to the console
    print('Caught error: $error');
    if (DebugMode.isInDebugMode) {
      // Print the full stacktrace in debug mode
      print(stackTrace);
      return;
    } else {
      // Send the Exception and Stacktrace to Sentry in Production mode
      sentryClient.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
