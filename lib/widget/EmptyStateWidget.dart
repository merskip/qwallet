import 'package:flutter/material.dart';

import 'VectorImage.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String text;

  const EmptyStateWidget({
    Key? key,
    this.icon,
    this.iconAsset,
    required this.text,
  })   : assert(icon != null || iconAsset != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null)
            Icon(
              icon,
              size: 72,
              color: Colors.grey,
            )
          else
            VectorImage(
              iconAsset!,
              size: Size.square(72),
              color: Colors.grey,
            ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
