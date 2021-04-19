import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ImageCroppingEditor.dart';

class PhotoEditorPage extends StatefulWidget {
  final File imageFile;

  const PhotoEditorPage({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  ui.Image? image;

  var selectedTab = _Tab.cropping;

  late ValueNotifier<CroppingState> croppingState;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    ui.decodeImageFromList(bytes, (image) {
      setState(() {
        this.image = image;
        final imageRect = Rect.fromLTWH(
          0.0,
          0.0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        croppingState = ValueNotifier(CroppingState(imageRect));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: image != null
          ? buildBodyWithImage(context, image!)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildBodyWithImage(BuildContext context, ui.Image image) {
    return Column(
      children: [
        Flexible(
          child: buildImage(context, image),
        ),
        buildToolbar(context),
      ],
    );
  }

  Widget buildImage(BuildContext context, ui.Image image) {
    final Widget imageEditor;
    switch (selectedTab) {
      case _Tab.cropping:
        imageEditor = ImageCroppingPreview(
          image: image,
          croppingState: croppingState,
        );
        break;
      case _Tab.coloring:
        imageEditor = buildImageColoring(context, image);
        break;
    }
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: imageEditor,
      ),
    );
  }

  Widget buildImageColoring(BuildContext context, ui.Image image) {
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: CustomPaint(
          painter: _ImageColoringPainter(
            image: image,
            croppingState: croppingState.value,
          ),
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Column(
      children: [
        if (selectedTab == _Tab.cropping)
          ImageCroppingToolbar(
            croppingState: croppingState,
          ),
        Container(
          height: 64,
          color: Colors.white10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16),
              buildToolbarIconButton(
                context,
                Icon(Icons.crop_rotate),
                _Tab.cropping,
              ),
              SizedBox(width: 16),
              buildToolbarIconButton(
                context,
                Icon(Icons.palette_outlined),
                _Tab.coloring,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.done),
                color: Colors.white,
                onPressed: () {},
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildToolbarIconButton(
    BuildContext context,
    Widget icon,
    _Tab tab,
  ) {
    final isSelected = tab == selectedTab;
    return IconButton(
      icon: icon,
      iconSize: 28,
      color: isSelected
          ? Theme.of(context).primaryColor
          : Theme.of(context).buttonColor,
      onPressed: () => setState(() {
        selectedTab = tab;
      }),
    );
  }
}

enum _Tab {
  cropping,
  coloring,
}

class _ImageColoringPainter extends CustomPainter {
  final ui.Image image;
  final CroppingState croppingState;

  _ImageColoringPainter({
    required this.image,
    required this.croppingState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.save();
    canvas.clipRect(croppingState.crop);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(croppingState.effectiveRotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.drawImage(image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ImageColoringPainter oldDelegate) {
    return true;
  }
}
