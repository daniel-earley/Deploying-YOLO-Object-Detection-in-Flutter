import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'model_prediction_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.high);
    await controller?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget cameraView() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CameraPreview(controller!), // Camera preview
        Positioned.fill(
          child: Image.asset(
            'assets/images/overlay.png',
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.8),
            colorBlendMode: BlendMode.modulate,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            color: const Color(0xff260530),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 95,
            width: 75,
            child: FloatingActionButton(
              onPressed: captureImage,
              backgroundColor: const Color(0xff260530),
              child: ClipOval(
                child: Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: const Icon(Icons.circle,
                            size: 55.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: 95,
            width: 115,
            child: FloatingActionButton(
              onPressed: pickImageFromGallery,
              backgroundColor: const Color(0xff260530),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white,
                    child: const Icon(Icons.image_search,
                        size: 55.0, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget imageSubmission() {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Image")),
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.75, // Half the screen height
            width: MediaQuery.of(context).size.width, // Full screen width
            child: Image.file(
              File(_capturedImage!.path),
              fit: BoxFit
                  .contain, // Cover the space without distorting the image aspect ratio
            ),
          ), // Display captured image
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: 'backButton',
                onPressed: () {
                  setState(() {
                    _capturedImage = null;
                  });
                },
                mini: true,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModelPredictionPage(
                          imageFile: File(_capturedImage!.path)),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.check),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    return _capturedImage == null ? cameraView() : imageSubmission();
  }

  Future captureImage() async {
    try {
      if (controller != null && controller!.value.isInitialized) {
        final image = await captureImageCamera();

        setState(() {
          _capturedImage = XFile(image);
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<String> captureImageCamera() async {
    if (!controller!.value.isInitialized) {
      throw Exception('Controller is not initialized');
    }
    final image = await controller!.takePicture();
    return image.path;
  }

  void pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _capturedImage = pickedFile;
        });
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
    }
  }
}
