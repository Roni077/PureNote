import 'package:flutter/foundation.dart';

class ErrorReporter {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      
      // TODO: Send to Firebase Crashlytics or Sentry here
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      debugPrint('CRASH_REPORTER CAUGHT ERROR: ${details.exceptionAsString()}');
    };
    
    // Catch asynchronous Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      // TODO: Send to Firebase Crashlytics or Sentry here
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint('CRASH_REPORTER CAUGHT ASYNC ERROR: $error');
      return true;
    };
  }
}
