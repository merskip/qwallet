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
        if (snapshot.hasError)
          return _error(snapshot);
        else if (snapshot.connectionState == ConnectionState.waiting)
          return _loading(snapshot);
        else
          return builder(context, snapshot.data);
      },
    );
  }

  _error(snapshot) {
    return Center(
      child: Row(children: <Widget>[
        Icon(Icons.error),
        Text("Error: ${snapshot.error}"),
      ]),
    );
  }

  _loading(snapshot) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
