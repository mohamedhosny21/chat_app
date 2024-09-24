import 'package:camera/camera.dart';
import 'package:chatify/features/home/stories/ui/widgets/take_picture_button.dart';
import 'package:flutter/material.dart';

class CameraViewScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraViewScreen({super.key, required this.cameras});

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    initializeControllerFuture = cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TakePictureButton(
                initializeControllerFuture: initializeControllerFuture,
                cameraController: cameraController);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
