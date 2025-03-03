import 'package:logging/logging.dart';

/// Custom log levels
const Level verbose =
    Level('VERBOSE', 850); // our custom level, similar to a verbose/info level
const Level debug = Level('DEBUG', 500); // roughly maps to FINE
const Level warning = Level('WARNING', 900); // roughly maps to WARNING
const Level error = Level('ERROR', 1000); // roughly maps to SEVERE

/// Global logger instance
final Logger appLogger = Logger('AppLogger');

/// Setup logger configuration - call this once at startup.
void setupLogger() {
  // Capture all messages. You can change this as needed.
  Logger.root.level = Level.ALL;

  // Listen for log records and print them directly
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time} - ${record.message}');
  });
}
