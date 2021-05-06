import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import '../../logger.dart';

class LogsPreviewPage extends StatefulWidget {
  const LogsPreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  _LogsPreviewPageState createState() => _LogsPreviewPageState();
}

class _LogsPreviewPageState extends State<LogsPreviewPage> {
  final List<LogEvent> showedStackStace = [];

  void onSelectedLogEvent(BuildContext context, LogEvent logEvent) {
    setState(() {
      if (showedStackStace.contains(logEvent))
        showedStackStace.remove(logEvent);
      else
        showedStackStace.add(logEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Logs"),
      ),
      body: Scrollbar(
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: logger.logs.length,
          itemBuilder: (context, index) {
            final logEvent = logger.logs[index];
            return buildLogEvent(context, logEvent);
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      ),
    );
  }

  Widget buildLogEvent(BuildContext context, LogEvent logEvent) {
    final isExpendable = logEvent.stackTrace != null;
    final isExtended = showedStackStace.contains(logEvent);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              buildLevel(context, logEvent),
              SizedBox(width: 8),
              Text(
                logEvent.getFormattedTime(),
                style: Theme.of(context).textTheme.caption,
              ),
              Spacer(),
              if (isExpendable)
                Icon(isExtended ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ]),
            SizedBox(height: 8),
            Text(
              logEvent.message,
              style: TextStyle(fontFamily: "Monospace", fontSize: 13),
            ),
            if (logEvent.exception != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  logEvent.exception.toString(),
                  style: TextStyle(
                    fontFamily: "Monospace",
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            if (isExtended)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  logEvent.stackTrace.toString(),
                  style: TextStyle(fontFamily: "Monospace", fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      onTap: isExpendable ? () => onSelectedLogEvent(context, logEvent) : null,
    );
  }

  Widget buildLevel(BuildContext context, LogEvent logEvent) {
    final color = getLevelColor(logEvent.level);

    return Badge(
      toAnimate: false,
      shape: BadgeShape.square,
      badgeColor: color,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      badgeContent: Text(
        logEvent.getLevelAsText(),
        style: TextStyle(
            color:
                color.computeLuminance() > 0.3 ? Colors.black : Colors.white),
      ),
    );
  }

  MaterialColor getLevelColor(Level level) {
    switch (level) {
      case Level.verbose:
        return Colors.grey;
      case Level.debug:
        return Colors.grey;
      case Level.info:
        return Colors.cyan;
      case Level.warning:
        return Colors.orange;
      case Level.error:
        return Colors.red;
    }
  }
}
