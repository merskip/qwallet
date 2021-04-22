import 'dart:io';
import 'dart:math';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../utils.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: buildCamera(context),
    );
  }

  Widget buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildCamera(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildCameraPreview(context),
          buildToolbar(context),
        ],
      ),
    );
  }

  Widget buildCameraPreview(BuildContext context) {
    return Expanded(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CameraAwesome(
              onPermissionsResult: (hasPermissions) {
                print("hasPermissions: $hasPermissions");
              },
              selectDefaultSize: (List<Size> availableSizes) {
                final targetSize = constraints.biggest *
                    MediaQuery.of(context).devicePixelRatio;
                print("Target size: $targetSize");
                Size bestSize = availableSizes.first;
                for (final size in availableSizes) {
                  if (getDifference(targetSize, size) <
                      getDifference(targetSize, bestSize)) {
                    bestSize = size;
                  }
                  print(
                      "Size: $size, aspect ratio: ${getHumanReadableAspectRatio(size.aspectRatio)}");
                }
                print("Best size: $bestSize");

                return targetSize;
              },
              captureMode: _captureMode,
              sensor: _sensor,
              switchFlashMode: _switchFlash,
              photoSize: _photoSize,
            );
          },
        ),
      ),
    );
  }

  num getDifference(Size targetSize, Size size) {
    return pow(targetSize.width - size.width, 2) +
        pow(targetSize.height - size.height, 2);
  }

  String getHumanReadableAspectRatio(double ratio) {
    if (ratio == 10 / 16) return "10:16";
    if (ratio == 9 / 16)
      return "9:16";
    else if (ratio == 3 / 4)
      return "3:4";
    else {
      for (var w = 1; w < 50; w++) {
        for (var h = 1; h < 50; h++) {
          if (ratio == w / h) return "$w:$h";
          if (ratio == h / w) return "$h:$w";
        }
      }
      return ratio.toStringAsFixed(1) + " (?)";
    }
  }

  Widget buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(width: 36 + 2 * 8),
          Spacer(),
          IconButton(
            icon: Icon(Icons.camera),
            color: Colors.white,
            iconSize: 48,
            onPressed: () => onSelectedTakePhoto(context),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.switch_camera),
            color: Colors.white,
            iconSize: 36,
            onPressed: () => onSelectedSwitchCamera(context),
          ),
        ],
      ),
    );
  }
}
