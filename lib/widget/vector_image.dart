import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'fake_html.dart' if (dart.library.html) 'dart:html' as html;
import 'fake_ui.dart' if (dart.library.html) 'dart:ui' as ui;

class VectorImage extends StatelessWidget {
  final String assetName;
  final Size size;
  final Color color;

  const VectorImage(this.assetName, {Key key, this.size, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildWeb(context);
    } else {
      return SvgPicture.asset(
        assetName,
        width: size?.width,
        height: size?.height,
        color: color,
      );
    }
  }

  Widget buildWeb(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString(assetName),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return buildHtmlSvgImage(snapshot.data);
        } else {
          return Container(
            width: size?.width,
            height: size?.height,
          );
        }
      },
    );
  }

  Widget buildHtmlSvgImage(String svgContent) {
    final viewId = getViewId();
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => buildSvgElement(svgContent),
    );
    return Container(
      width: size?.width,
      height: size?.height,
      child: HtmlElementView(viewType: viewId),
    );
  }

  buildSvgElement(String svgContent) {
    final String base64 = base64Encode(utf8.encode(svgContent));
    final String base64String = 'data:image/svg+xml;base64,$base64';

    final iconElement = html.DivElement();
    iconElement.style.maskImage = "url($base64String)";
    if (size != null)
      iconElement.style.maskSize = "${size.width}px ${size.height}px";
    else
      iconElement.style.maskSize = "100%";
    if (color != null)
      iconElement.style.backgroundColor = "${colorToHex(color)}";
    return iconElement;
  }

  String getViewId() {
    final hashGuts =
        [assetName, size?.width, size?.height, color.value].join("-");
    final hash = sha256.convert(utf8.encode(hashGuts)).toString();
    return "img-svg-$hash";
  }

  String colorToHex(Color color) => '#'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}';
}
