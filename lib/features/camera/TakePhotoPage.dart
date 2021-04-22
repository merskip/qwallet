import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../utils.dart';
import '../../utils/IterableFinding.dart';
import 'PhotoEditorPage.dart';

class TakePhotoPage extends StatefulWidget {
  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final _pictureController = PictureController();
  final _switchFlash = ValueNotifier(CameraFlashes.NONE);
  final _sensor = ValueNotifier(Sensors.BACK);
  final _captureMode = ValueNotifier(CaptureModes.PHOTO);
  final _photoSize = ValueNotifier(Size(1280, 720));

  void onSelectedSwitchCamera(BuildContext context) {
    _sensor.value =
        _sensor.value == Sensors.BACK ? Sensors.FRONT : Sensors.BACK;
  }

  void onSelectedTakePhoto(BuildContext context) async {
    final photoFile = await getNewPhotoFile();
    await _pictureController.takePicture(photoFile.path);

    pushPage(
      context,
      builder: (context) => PhotoEditorPage(
        imageFile: photoFile,
      ),
    );
  }

  Future<File> getNewPhotoFile() async {
    final picturesDirectories = await getExternalStorageDirectories(
      type: StorageDirectory.pictures,
    );
    final directory =
        picturesDirectories?.first ?? await getApplicationDocumentsDirectory();
    final fileName = Uuid().v1();
    return File(directory.path + "/$fileName.jpg");
  }

  @override
  void dispose() {
    _switchFlash.dispose();
    _sensor.dispose();
    _captureMode.dispose();
    _photoSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: buildCamera(context),
    );
  }

  Widget buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildCamera(BuildContext context) {
    return Stack(
      children: [
        buildCameraPreview(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: buildToolbar(context),
        ),
      ],
    );
  }

  Widget buildCameraPreview(BuildContext context) {
    print("Using size: ${_photoSize.value}");
    return CameraAwesome(
      onPermissionsResult: (result) {},
      selectDefaultSize: findStandardSize,
      captureMode: _captureMode,
      sensor: _sensor,
      switchFlashMode: _switchFlash,
      photoSize: _photoSize,
    );
  }

  Size findStandardSize(List<Size> availableSizes) {
    return availableSizes.findFirstOrNull((size) => size == Sizes.fullHd) ??
        availableSizes.findFirstOrNull((size) => size == Sizes.hd)!;
  }

  Widget buildToolbar(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.flash_auto),
              color: Colors.white,
              iconSize: 32,
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.camera),
              color: Colors.white,
              iconSize: 56,
              onPressed: () => onSelectedTakePhoto(context),
            ),
            IconButton(
              icon: Icon(Icons.switch_camera),
              color: Colors.white,
              iconSize: 32,
              onPressed: () => onSelectedSwitchCamera(context),
            ),
          ],
        ),
      ),
    );
  }
}

class Sizes {
  static Size hd = Size(1280, 720);
  static Size fullHd = Size(1920, 1080);
}
