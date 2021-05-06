import 'package:flutter/material.dart';

import '../../logger.dart';

class LogsPreviewPage extends StatelessWidget {
  const LogsPreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Logs"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(logger.logsAsText),
        ),
      ),
    );
  }
}
