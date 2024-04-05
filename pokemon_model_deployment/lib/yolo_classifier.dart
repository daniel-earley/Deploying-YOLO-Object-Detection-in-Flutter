import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;

class YoloClassifier {
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;

  YoloClassifier() {
    vision = FlutterVision();
    yoloResults = [];
  }

  // This function is taken from the example code in the flutter_vision repository
  // Source: Vladimir Hudnitsky. (2024). main.dart in flutter_vision example. flutter_vision.
  // Retrieved 2024-04-04 from https://github.com/vladiH/flutter_vision/blob/master/example/lib/main.dart
  Future<void> loadModel() async {
    // Load your YOLO model here
    await vision.loadYoloModel(
        labels: 'assets/text_files/labels.txt',
        modelPath: 'assets/models/basic_pokemon_model_float16.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: true);
  }

  // This function is adapted the example code in the flutter_vision repository
  // Source: Vladimir Hudnitsky. (2024). main.dart in flutter_vision example. flutter_vision.
  // Retrieved 2024-04-04 from https://github.com/vladiH/flutter_vision/blob/master/example/lib/main.dart
  Future<List<Map<String, dynamic>>> inferenceUsingYOLO(File imageFile) async {
    yoloResults.clear();
    Uint8List byte = await imageFile.readAsBytes();
    final image = await convertFileToImage(imageFile);
    var imageHeight = image!.height;
    var imageWidth = image!.width;
    final result = await vision.yoloOnImage(
        bytesList: byte,
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      yoloResults = result;
    }
    return yoloResults;
  }

  Future<img.Image?> convertFileToImage(File imageFile) async {
    // Read the image file into a byte array
    Uint8List imageData = await imageFile.readAsBytes();

    // Decode the image from the byte array to get the img.Image object
    img.Image? image = img.decodeImage(imageData);

    return image;
  }
}
