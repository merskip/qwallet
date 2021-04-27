import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qwallet/features/files/UniversalFile.dart';
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
  final _photoSize = ValueNotifier(Size.zero);

  void onSelectedSwitchFlash(BuildContext context) {
    _switchFlash.value = _getNextCameraFlash(_switchFlash.value);
  }

  void onSelectedAlwaysFlash(BuildContext context) {
    _switchFlash.value = CameraFlashes.ALWAYS;
  }

  void onSelectedSwitchCamera(BuildContext context) {
    _sensor.value = _getNextCameraSensor(_sensor.value);
  }

  void onSelectedTakePhoto(BuildContext context) async {
    var photoFile = await getNewPhotoFile();
    await _pictureController.takePicture(photoFile.path);

    photoFile = await pushPage(
      context,
      builder: (context) => PhotoEditorPage(
        imageFile: photoFile,
      ),
    );
    Navigator.of(context).pop(LocalUniversalFile(photoFile));
  }

  Future<File> getNewPhotoFile() async {
    final directory = await getTemporaryDirectory();
    final fileName = Uuid().v4() + ".jpg";
    return File("${directory.path}/$fileName");
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
        actions: [
          ValueListenableBuilder(
            valueListenable: _photoSize,
            builder: (context, Size size, child) => Center(
              child: Text("${size.width.round()} x ${size.height.round()} "),
            ),
          ),
        ],
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
        Sizes.hd;
  }

  Widget buildToolbar(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ValueListenableBuilder(
              valueListenable: _switchFlash,
              builder: (context, value, child) => GestureDetector(
                child: IconButton(
                  icon: Icon(
                    _getCameraFlashIcon(_switchFlash.value),
                  ),
                  color: _switchFlash.value == CameraFlashes.ALWAYS
                      ? Colors.yellow
                      : Colors.white,
                  iconSize: 32,
                  onPressed: () => onSelectedSwitchFlash(context),
                ),
                onLongPress: () => onSelectedAlwaysFlash(context),
              ),
            ),
            IconButton(
              icon: Icon(Icons.camera),
              color: Colors.white,
              iconSize: 56,
              onPressed: () => onSelectedTakePhoto(context),
            ),
            ValueListenableBuilder(
              valueListenable: _sensor,
              builder: (context, value, child) => IconButton(
                icon: Icon(
                  _getCameraSensorIcon(_sensor.value),
                ),
                color: Colors.white,
                iconSize: 32,
                onPressed: () => onSelectedSwitchCamera(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCameraSensorIcon(Sensors sensor) {
    switch (sensor) {
      case Sensors.BACK:
        return Icons.camera_rear;
      case Sensors.FRONT:
        return Icons.camera_front;
    }
  }

  static IconData _getCameraFlashIcon(CameraFlashes flash) {
    switch (flash) {
      case CameraFlashes.NONE:
        return Icons.flash_off;
      case CameraFlashes.ON:
        return Icons.flash_on;
      case CameraFlashes.AUTO:
        return Icons.flash_auto;
      case CameraFlashes.ALWAYS:
        return Icons.flash_on;
    }
  }

  static Sensors _getNextCameraSensor(Sensors now) {
    switch (now) {
      case Sensors.BACK:
        return Sensors.FRONT;
      case Sensors.FRONT:
        return Sensors.BACK;
    }
  }

  static CameraFlashes _getNextCameraFlash(CameraFlashes now) {
    switch (now) {
      case CameraFlashes.NONE:
        return CameraFlashes.AUTO;
      case CameraFlashes.AUTO:
        return CameraFlashes.ON;
      case CameraFlashes.ON:
        return CameraFlashes.NONE;
      case CameraFlashes.ALWAYS:
        return CameraFlashes.NONE;
    }
  }
}

class Sizes {
  static Size hd = Size(1280, 720);
  static Size fullHd = Size(1920, 1080);
}
