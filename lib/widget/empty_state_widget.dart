import 'package:flutter/material.dart';

import 'vector_image.dart';

class EmptyStateWidget extends StatelessWidget {
  final String icon;
  final String text;

  const EmptyStateWidget({
    Key key,
    this.icon,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          VectorImage(
            icon,
            size: Size.square(72),
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
