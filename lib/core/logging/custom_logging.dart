import 'package:logger/logger.dart';

enum LogLevel {
  none, // No logging
  errors, // Only errors and warnings
  verbose, // All logs including debug info
}

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final emoji = _getEmoji(event.level);
    final level = event.level.name.toUpperCase();
    final message = event.message;
    final time = DateTime.now().toString().substring(11, 23); // HH:MM:SS.mmm

    return ['$time $emoji $level: $message'];
  }

  String _getEmoji(Level level) {
    switch (level) {
      case Level.trace:
        return '🔍';
      case Level.debug:
        return '🐛';
      case Level.info:
        return '💡';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.fatal:
        return '💀';
      default:
        return '📝';
    }
  }
}

class AppLogger {
  static Logger? _logger;
  static LogLevel _currentLevel = LogLevel.verbose; // Default to verbose for development

  // Per-file logging control
  static final Map<String, LogLevel> _fileLogLevels = {};

  // Initialize logger with custom configuration
  static Logger get instance {
    _logger ??= Logger(printer: SimpleLogPrinter(), output: ConsoleOutput());
    return _logger!;
  }

  // Global logging control
  static LogLevel get level => _currentLevel;

  static void setLevel(LogLevel level) {
    _currentLevel = level;
  }

  // Per-file logging control
  static void setFileLevel(String fileName, LogLevel level) {
    _fileLogLevels[fileName] = level;
  }

  static LogLevel getFileLevel(String fileName) {
    return _fileLogLevels[fileName] ?? _currentLevel;
  }

  static void clearFileLevel(String fileName) {
    _fileLogLevels.remove(fileName);
  }

  static void clearAllFileLevels() {
    _fileLogLevels.clear();
  }

  // Convenience methods
  static bool get isVerbose => _currentLevel == LogLevel.verbose;
  static bool get showErrors => _currentLevel != LogLevel.none;
  static bool get showDebug => _currentLevel == LogLevel.verbose;
  static bool get showInfo => _currentLevel == LogLevel.verbose;
  static bool get showWarnings => _currentLevel != LogLevel.none;

  // Per-file convenience methods
  static bool isVerboseForFile(String fileName) {
    return getFileLevel(fileName) == LogLevel.verbose;
  }

  static bool showErrorsForFile(String fileName) {
    return getFileLevel(fileName) != LogLevel.none;
  }

  static bool showDebugForFile(String fileName) {
    return getFileLevel(fileName) == LogLevel.verbose;
  }

  static bool showInfoForFile(String fileName) {
    return getFileLevel(fileName) == LogLevel.verbose;
  }

  static bool showWarningsForFile(String fileName) {
    return getFileLevel(fileName) != LogLevel.none;
  }

  // Environment-based configuration
  static void configureForEnvironment({bool isDebug = false}) {
    if (isDebug) {
      setLevel(LogLevel.verbose);
    } else {
      setLevel(LogLevel.errors);
    }
  }

  // Professional logging methods with file context
  static void debug(String message, {String? fileName, String? function}) {
    if (!showDebug) return;
    final context = _buildContext(fileName, function);
    instance.d('$context: $message');
  }

  static void info(String message, {String? fileName, String? function}) {
    if (!showInfo) return;
    final context = _buildContext(fileName, function);
    instance.i('$context: $message');
  }

  static void warning(String message, {String? fileName, String? function}) {
    if (!showWarnings) return;
    final context = _buildContext(fileName, function);
    instance.w('$context: $message');
  }

  static void error(String message, {String? fileName, String? function, dynamic error, StackTrace? stackTrace}) {
    if (!showErrors) return;
    final context = _buildContext(fileName, function);
    instance.e('$context: $message', error: error, stackTrace: stackTrace);
  }

  // Per-file logging methods
  static void debugForFile(String fileName, String message, {String? function}) {
    if (!showDebugForFile(fileName)) return;
    final context = _buildContext(fileName, function);
    instance.d('$context: $message');
  }

  static void infoForFile(String fileName, String message, {String? function}) {
    if (!showInfoForFile(fileName)) return;
    final context = _buildContext(fileName, function);
    instance.i('$context: $message');
  }

  static void warningForFile(String fileName, String message, {String? function}) {
    if (!showWarningsForFile(fileName)) return;
    final context = _buildContext(fileName, function);
    instance.w('$context: $message');
  }

  static void errorForFile(String fileName, String message, {String? function, dynamic error, StackTrace? stackTrace}) {
    if (!showErrorsForFile(fileName)) return;
    final context = _buildContext(fileName, function);
    instance.e('$context: $message', error: error, stackTrace: stackTrace);
  }

  // Helper method to build context string
  static String _buildContext(String? fileName, String? function) {
    if (fileName != null && function != null) {
      return '[$fileName/$function]';
    } else if (fileName != null) {
      return '[$fileName]';
    } else if (function != null) {
      return '[Unknown/$function]';
    }
    return '[Unknown]';
  }

  // Description helpers
  static String get levelDescription {
    switch (_currentLevel) {
      case LogLevel.none:
        return 'No Logging';
      case LogLevel.errors:
        return 'Errors Only';
      case LogLevel.verbose:
        return 'Verbose (All Logs)';
    }
  }

  static List<LogLevel> get allLevels => LogLevel.values;
}

// Convenient static methods for quick access
class Log {
  static void d(String message, {String? fileName, String? function}) => AppLogger.debug(message, fileName: fileName, function: function);

  static void i(String message, {String? fileName, String? function}) => AppLogger.info(message, fileName: fileName, function: function);

  static void w(String message, {String? fileName, String? function}) => AppLogger.warning(message, fileName: fileName, function: function);

  static void e(String message, {String? fileName, String? function, dynamic error, StackTrace? stackTrace}) =>
      AppLogger.error(message, fileName: fileName, function: function, error: error, stackTrace: stackTrace);
}
