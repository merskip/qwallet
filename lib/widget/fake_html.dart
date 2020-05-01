class ImageElement {
  ImageElement({src, height, width});
}

class DivElement {
  String text;
  // ignore: missing_return
  CssStyleDeclaration get style {}

  DivElement();
}

class CssStyleDeclaration {

  set maskImage(String value) {}
  set maskSize(String value) {}
  set backgroundColor(String value) {}
}