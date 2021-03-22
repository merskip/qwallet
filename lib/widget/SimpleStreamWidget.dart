import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';

typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class SimpleStreamWidget<T> extends StatelessWidget {
  final Stream<T> stream;
  final ValueWidgetBuilder<T> builder;
  final WidgetBuilder? loadingBuilder;

  const SimpleStreamWidget(
      {Key? key,
      required this.stream,
      required this.builder,
      this.loadingBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<T> snapshot) {
        _debugSnapshot(snapshot);
        if (snapshot.hasError)
          return _error(context, snapshot);
        else if (snapshot.hasData) {
          final data = snapshot.data;
          if (data is Model && !data.documentSnapshot.exists)
            return buildLoading(context);
          return builder(context, data!);
        } else
          return buildLoading(context);
      },
    );
  }

  _debugSnapshot(AsyncSnapshot<T> snapshot) {
    String id = stream.hashCode.toRadixString(16).padLeft(8, '0');

    String typeName = "$T";
    if (snapshot.data is List<List<dynamic>>) {
      final list = snapshot.data as List<List<dynamic>>;
      typeName = "List<${list.first?.runtimeType}>";
    }

    String stateIcon = HashMap.of({
      ConnectionState.none: "⛔",
      ConnectionState.waiting: "⏳",
      ConnectionState.active: "🔁",
      ConnectionState.done: "✅",
    })[snapshot.connectionState]!;
    final state =
        snapshot.connectionState.toString().replaceFirst("ConnectionState", "");

    print("Stream-$id "
        "type=$typeName "
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
      BuildContext context, String description, StackTrace? stackTrace) {
    final content = SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade500),
            SizedBox(height: 16),
            SelectableText(
              "Error: $description",
              style: TextStyle(
                fontFamily: "monospace",
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
                    fontFamily: "monospace",
                    color: Colors.red.shade300,
                    fontSize: 8,
                  ),
                ),
              ),
          ]),
        ),
      ),
    );

    final existsScaffold = Scaffold.maybeOf(context) != null;
    return existsScaffold
        ? content
        : Scaffold(
            body: content,
            appBar: AppBar(backgroundColor: Colors.red),
          );
  }

  Widget buildLoading(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder!(context);
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
