import 'package:flutter/gestures.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/widgets.dart';

/// - from: https://stackoverflow.com/a/57828692
class HandCursor extends MouseRegion {
  HandCursor({Widget child})
      : super(
          onEnter: (PointerEnterEvent event) {
            html.document.body.style.cursor = "pointer";
          },
          onExit: (PointerExitEvent event) {
            html.document.body.style.removeProperty("cursor");
          },
          child: child,
        );
}
