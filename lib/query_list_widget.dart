import 'package:QWallet/firebase_service.dart';
import 'package:flutter/material.dart';

class QueryListWidget<T> extends StatelessWidget {
  final Stream<TypedQuerySnapshot<T>> stream;
  final Widget Function(TypedQuerySnapshot<T>) builder;

  const QueryListWidget({Key key, this.stream, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<TypedQuerySnapshot<T>> snapshot) {
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
