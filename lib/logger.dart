import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'utils/IterableFinding.dart';

enum Level {
  verbose,
  debug,
  info,
  warning,
  error,
}

class LogEvent {
  final Level level;
  final DateTime time;
  final String message;
  final dynamic? exception;
  final StackTrace? stackTrace;

  LogEvent(
    this.level,
    this.time,
    this.message,
    this.exception,
    this.stackTrace,
  );

  String toSimpleText() {
    var result = "[${getFormattedTime()}] "
        "[${getLevelAsText()}] "
        "$message";

    if (exception != null) result += "\n" + exception.toString();
    if (stackTrace != null) result += "\n" + stackTrace.toString();
    return result;
  }

  String getFormattedTime() {
    return DateFormat("yyyy-MM-dd HH:mm:ss.SSSS").format(time) +
        " " +
        time.timeZoneName;
  }

  String getLevelAsText() {
    switch (level) {
      case Level.verbose:
        return "verbose";
      case Level.debug:
        return "debug";
      case Level.info:
        return "info";
      case Level.warning:
        return "warning";
      case Level.error:
        return "error";
    }
  }
}

class Logger {
  final List<LogEvent> logs = [];

  String get logsAsText =>
      logger.logs.map((log) => log.toSimpleText()).join("\n");

  final List<LogPrinter> printers;

  bool get hasWarningOrErrorLogs => hasWarningLogs || hasErrorLogs;

  bool get hasWarningLogs =>
      logs.findFirstOrNull((log) => log.level == Level.warning) != null;

  bool get hasErrorLogs =>
      logs.findFirstOrNull((log) => log.level == Level.error) != null;

  Logger({required this.printers});

  void verbose(String message) => log(Level.verbose, message);

  void debug(String message) => log(Level.debug, message);

  void info(String message) => log(Level.info, message);

  void warning(String message, {dynamic? exception, StackTrace? stackTrace}) =>
      log(Level.warning, message, exception, stackTrace);

  void error(String message, {dynamic? exception, StackTrace? stackTrace}) =>
      log(Level.error, message, exception, stackTrace);

  void log(
    Level level,
    String message, [
    dynamic? exception,
    StackTrace? stackTrace,
  ]) {
    final logEvent =
        LogEvent(level, DateTime.now(), message, exception, stackTrace);
    logs.add(logEvent);
    for (final printer in printers) {
      printer.printLog(logEvent);
    }
  }

  void clearAllLogs() {
    logs.clear();
  }
}

abstract class LogPrinter {
  void printLog(LogEvent logEvent);
}

class ConsoleLogPrinter extends LogPrinter {
  @override
  void printLog(LogEvent logEvent) {
    final message =
        _beginColor(logEvent.level) + logEvent.toSimpleText() + _endColor();
    print(message);
  }

  String _beginColor(Level level) {
    switch (level) {
      case Level.verbose:
        return "\x1B[37m";
      case Level.debug:
        return "\x1B[37m";
      case Level.info:
        return "\x1B[36m";
      case Level.warning:
        return "\x1B[33m";
      case Level.error:
        return "\x1B[31m";
    }
  }

  String _endColor() {
    return "\x1B[0m";
  }
}

class FirebaseCrashlyticsPrinter extends LogPrinter {
  @override
  void printLog(LogEvent logEvent) {
    FirebaseCrashlytics.instance.log(logEvent.toSimpleText());
  }
}

class LoggerNavigatorObserver extends NavigatorObserver {
  final Logger logger;

  LoggerNavigatorObserver(this.logger);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.info("Navigation didReplace: $oldRoute -> $newRoute");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info("Navigation didRemove: $previousRoute -> $route");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info("Navigation didPop: $previousRoute -> $route");
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info("Navigation override: $previousRoute -> $route");
  }
}

final logger = Logger(
  printers: [
    ConsoleLogPrinter(),
    FirebaseCrashlyticsPrinter(),
  ],
);
