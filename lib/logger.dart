import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/main.dart';

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

  void verbose(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) =>
      log(Level.verbose, message);

  void debug(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) =>
      log(Level.debug, message);

  void info(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) =>
      log(Level.info, message);

  void warning(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) =>
      log(Level.warning, message, exception, stackTrace);

  void error(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) =>
      log(Level.error, message, exception, stackTrace);

  void log(
    Level level,
    String message, [
    dynamic exception,
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
    crashlytics?.log(logEvent.toSimpleText());
  }
}

class LoggerNavigatorObserver extends NavigatorObserver {
  final Logger logger;

  LoggerNavigatorObserver(this.logger);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.info(
        "Navigation didReplace:\n${_transitionToText(oldRoute, newRoute)}");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info(
        "Navigation didRemove:\n${_transitionToText(previousRoute, route)}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger
        .info("Navigation didPop:\n${_transitionToText(route, previousRoute)}");
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info(
        "Navigation didPush:\n${_transitionToText(previousRoute, route)}");
  }

  String _transitionToText(Route<dynamic>? fromRoute, Route<dynamic>? toRoute) {
    return " - from: ${_routeToText(fromRoute)}\n - to: ${_routeToText(toRoute)}";
  }

  String _routeToText(Route<dynamic>? route) {
    if (route == null) return "null";
    return "name=\"${route.settings.name}\", "
        "type=${route.runtimeType}, "
        "arguments=${route.settings.arguments}, "
        "currentResult=${route.currentResult}";
  }
}

final logger = Logger(
  printers: [
    ConsoleLogPrinter(),
    FirebaseCrashlyticsPrinter(),
  ],
);
