import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

typedef WidgetBuilder<T> = Widget Function(BuildContext context, T snapshot);

class SimpleStreamWidget<T> extends StatelessWidget {
  final Stream<T> stream;
  final WidgetBuilder<T> builder;

  const SimpleStreamWidget(
      {Key key, @required this.stream, @required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<T> snapshot) {
        _debugSnapshot(snapshot);
        if (snapshot.hasError)
          return _error(snapshot);
        else if (snapshot.hasData)
          return builder(context, snapshot.data);
        else
          return _loading(snapshot);
      },
    );
  }

  _debugSnapshot(AsyncSnapshot<T> snapshot) {
    final state =
        snapshot.connectionState.toString().replaceFirst("ConnectionState", "");
    String stateIcon = HashMap.of({
      ConnectionState.none: "⛔",
      ConnectionState.waiting: "⏳",
      ConnectionState.active: "🔁",
      ConnectionState.done: "✅",
    })[snapshot.connectionState];

    print("[Snapshot $T] "
        "state=($stateIcon $state) "
        "hasData=${snapshot.hasData} "
        "hasError=${snapshot.hasError}");
  }

  _error(AsyncSnapshot<T> snapshot) {
    final error = snapshot.error as Error;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: <Widget>[
          Icon(Icons.error, size: 48, color: Colors.red.shade500),
          Text(
            "Error: $error\n\n${error.stackTrace}",
            style: TextStyle(
              fontFamily: Platform.isIOS ? "Courier" : "monospace",
              color: Colors.red.shade400,
            ),
          ),
        ]),
      ),
    );
  }

  _loading(snapshot) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
