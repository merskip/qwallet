import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qwallet/features/camera/ImageColoringEditor.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import 'ImageCroppingEditor.dart';
import 'MutableImage.dart';

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
    var mutableImage = await MutableImage.fromImage(originalImage);

    if (croppingState != null) {
      mutableImage = mutableImage.rotate(
        croppingState.effectiveRotation,
        keepSize: true,
      );
      mutableImage = mutableImage.crop(
        croppingState.crop.left.toInt(),
        croppingState.crop.top.toInt(),
        croppingState.crop.width.toInt(),
        croppingState.crop.height.toInt(),
      );
    }
    if (coloringState != null) {
      mutableImage =
          mutableImage.brightness((coloringState.brightness * 255).round());
      mutableImage =
          mutableImage.contrast((coloringState.contrast * 255).round());
    }

    return await mutableImage.toImage();
  }

  void onSelectedDone(BuildContext context) async {
    final image = await apply(
      originalImage!,
      croppingState: croppingState.value,
      coloringState: coloringState.value,
    );
    final mutableImage = await MutableImage.fromImage(image);
    await mutableImage.saveToFile(widget.imageFile);

    Navigator.of(context).pop(widget.imageFile);
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
      case _Tab.coloring:
        return SimpleStreamWidget(
          stream: apply(originalImage, croppingState: croppingState.value)
              .asStream(),
          builder: (BuildContext context, ui.Image image) {
            return SizedBox(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              child: ImageColoringPreview(
                originalImage: image,
                state: coloringState,
              ),
            );
          },
        );
    }
  }

  Widget buildToolbar(BuildContext context) {
    return Column(
      children: [
        if (selectedTab == _Tab.cropping)
          ImageCroppingToolbar(
            state: croppingState,
          ),
        if (selectedTab == _Tab.coloring)
          ImageColoringToolbar(
            state: coloringState,
          ),
        Container(
          height: 64,
          color: Colors.white10,
          child: SafeArea(
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
                  onPressed: () => onSelectedDone(context),
                ),
                SizedBox(width: 16),
              ],
            ),
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
