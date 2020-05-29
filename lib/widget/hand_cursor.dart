import 'package:flutter/gestures.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/widgets.dart';

/// - from: https://stackoverflow.com/a/57828692
class HandCursor extends MouseRegion {

  HandCursor({Widget child}) : super(
      onHover: (PointerHoverEvent evt) {
        html.document.body.style.cursor = "pointer";
      },
      onExit: (PointerExitEvent evt) {
        // set cursor's style 'default' to return it to the original state
        html.document.body.style.removeProperty("cursor");
      },
      child: child
  );
}