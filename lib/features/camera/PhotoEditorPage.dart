import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qwallet/features/camera/ImageColoringEditor.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

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
  ui.Image? originalImage;

  var selectedTab = _Tab.cropping;

  late ValueNotifier<CroppingState> croppingState;
  late ValueNotifier<ColoringState> coloringState;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    ui.decodeImageFromList(bytes, (image) {
      setState(() {
        this.originalImage = image;
        final imageRect = Rect.fromLTWH(
          0.0,
          0.0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        croppingState = ValueNotifier(CroppingState(imageRect));
        coloringState = ValueNotifier(ColoringState());
      });
    });
  }

  Future<ui.Image> apply(
    ui.Image originalImage, {
    CroppingState? croppingState,
    ColoringState? coloringState,
  }) async {
    var size = Size(
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (croppingState != null) {
      canvas.clipRect(Offset.zero & croppingState.crop.size);
      canvas.translate(-croppingState.crop.left, -croppingState.crop.top);

      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(croppingState.rotation);
      canvas.translate(-size.width / 2, -size.height / 2);
      size = croppingState.crop.size;
    }
    canvas.drawImage(originalImage, Offset.zero, Paint());

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: originalImage != null
          ? buildBodyWithImage(context, originalImage!)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildBodyWithImage(BuildContext context, ui.Image image) {
    return Column(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: FittedBox(
            child: buildImage(context, image),
          ),
        ),
        buildToolbar(context),
      ],
    );
  }

  Widget buildImage(BuildContext context, ui.Image originalImage) {
    switch (selectedTab) {
      case _Tab.cropping:
        return SizedBox(
          width: originalImage.width.toDouble(),
          height: originalImage.height.toDouble(),
          child: ImageCroppingPreview(
            image: originalImage,
            state: croppingState,
          ),
        );
        break;
      case _Tab.coloring:
        return SimpleStreamWidget(
          stream: apply(originalImage, croppingState: croppingState.value)
              .asStream(),
          builder: (BuildContext context, ui.Image image) {
            return SizedBox(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              child: ImageColoringPreview(
                image: image,
                state: coloringState,
              ),
            );
          },
        );
        break;
    }
  }

  Widget buildToolbar(BuildContext context) {
    return Column(
      children: [
        if (selectedTab == _Tab.cropping)
          ImageCroppingToolbar(
            state: croppingState,
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
