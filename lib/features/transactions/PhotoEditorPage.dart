import 'dart:io';

import 'package:flutter/material.dart';

class PhotoEditorPage extends StatelessWidget {
  final File imageFile;

  const PhotoEditorPage({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Image.file(imageFile),
    );
  }
}
