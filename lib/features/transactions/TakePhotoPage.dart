import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePhotoPage extends StatefulWidget {
  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage>
    with WidgetsBindingObserver {
  late CameraController controller;
  late final List<CameraDescription> cameras;
  var isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      print(cameraController.description);
    }
  }

  void _setupCamera() async {
    cameras = await availableCameras();
    final defaultCamera = getDefaultCamera();
    setCamera(defaultCamera);
  }

  CameraDescription getDefaultCamera() {
    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  void setCamera(CameraDescription camera) async {
    if (isInitialized) {
      controller.dispose();
      // NOTE: Fixing crash on Android
      await Future.delayed(Duration(milliseconds: 1));
    }

    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onSelectedSwitchCamera(BuildContext context) {
    final currentCameraIndex = cameras.indexOf(controller.description);
    if (currentCameraIndex + 1 < cameras.length) {
      setCamera(cameras[currentCameraIndex + 1]);
    } else {
      setCamera(cameras[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: !isInitialized ? buildLoading(context) : buildCamera(context),
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
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: CameraPreview(
        controller,
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 36 + 2 * 8),
          Spacer(),
          IconButton(
            icon: Icon(Icons.camera),
            color: Colors.white,
            iconSize: 48,
            onPressed: () {},
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
