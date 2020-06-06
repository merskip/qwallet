import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScanReceiptPage extends StatefulWidget {
  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {

  CameraController controller;

@override
  void initState() {
    _initCamera();
    super.initState();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: controller != null && controller.value.isInitialized
          ? Center(
            child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller)),
          )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
