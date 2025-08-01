import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class SimpleStreamWidget<T> extends StatelessWidget {
  final Stream<T> stream;
  final ValueWidgetBuilder<T> builder;
  final WidgetBuilder loadingBuilder;

  const SimpleStreamWidget({
    Key key,
    @required this.stream,
    @required this.builder,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<T> snapshot) {
        _debugSnapshot(snapshot);
        if (snapshot.hasError)
          return _error(context, snapshot);
        else if (snapshot.hasData)
          return builder(context, snapshot.data);
        else
          return buildLoading(context);
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

    String typeName = "$T";

    if (snapshot.data is List<List<dynamic>>) {
      final list = snapshot.data as List<List<dynamic>>;
      typeName = "List<${list.first?.runtimeType}>";
    }

    print("[Snapshot $typeName] "
        "state=($stateIcon $state) "
        "hasData=${snapshot.hasData} "
        "hasError=${snapshot.hasError}");
  }

  Widget _error(BuildContext context, Object error) {
    if (error is Error) {
      return buildError(context, error.toString(), error.stackTrace);
    } else {
      return buildError(context, error.toString(), null);
    }
  }

  Widget buildError(
      BuildContext context, String description, StackTrace stackTrace) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: <Widget>[
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade500),
          SizedBox(height: 16),
          SelectableText(
            "Error: $description",
            style: TextStyle(
              fontFamily: Platform.isIOS ? "Courier" : "monospace",
              color: Colors.red.shade500,
              fontSize: 12,
            ),
          ),
          if (stackTrace != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                stackTrace.toString(),
                style: TextStyle(
                  fontFamily: Platform.isIOS ? "Courier" : "monospace",
                  color: Colors.red.shade300,
                  fontSize: 8,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget buildLoading(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder(context);
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
