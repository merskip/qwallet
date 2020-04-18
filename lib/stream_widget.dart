import 'package:flutter/material.dart';

class StreamWidget<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(T) builder;

  const StreamWidget({Key key, this.stream, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError)
          return _error(snapshot);
        else if (snapshot.connectionState == ConnectionState.waiting)
          return _loading(snapshot);
        else
          return builder(snapshot.data);
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
