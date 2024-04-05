import 'dart:io';
import 'package:flutter/material.dart';
import 'yolo_classifier.dart';

class ModelPredictionPage extends StatefulWidget {
  final File imageFile;

  const ModelPredictionPage({super.key, required this.imageFile});

  @override
  _ModelPredictionPageState createState() => _ModelPredictionPageState();
}

class _ModelPredictionPageState extends State<ModelPredictionPage> {
  late YoloClassifier yoloClassifier;
  String statusMessage = "Processing";
  bool isLoading = true;
  List<Map<String, dynamic>>? inferenceResults;

  @override
  void initState() {
    super.initState();
    yoloClassifier = YoloClassifier();
    loadModelAndInfer();
  }

  void loadModelAndInfer() async {
    await yoloClassifier.loadModel();
    inferenceResults =
        await yoloClassifier.inferenceUsingYOLO(widget.imageFile);
    if (inferenceResults != null && inferenceResults!.isNotEmpty) {
      // Assuming the label is stored in 'label' key in the result map
      print(inferenceResults![0]);
      setState(() {
        statusMessage =
            "Detected ${inferenceResults!.first['tag']} \nwith ${(inferenceResults!.first['box'][4] * 100).toStringAsFixed(0)}% confidence";
      });
    } else {
      setState(() {
        statusMessage = "No objects detected";
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Return the processing widget if isLoading is true
      return processing();
    } else {
      // Return the results widget if isLoading is false
      return results();
    }
  }

  Widget processing() {
    return Scaffold(
      appBar: AppBar(title: const Text("Model Prediction")),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(statusMessage, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              )
            : Text(statusMessage, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget results() {
    return Scaffold(
      appBar: AppBar(title: const Text("Model Prediction")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.75, // Half the screen height
            width: MediaQuery.of(context).size.width, // Full screen width
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Center(
              child: isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          statusMessage,
                          style: const TextStyle(
                              fontSize: 24), // Increased font size
                        ),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
                    )
                  : Text(
                      statusMessage,
                      style:
                          const TextStyle(fontSize: 24), // Increased font size
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
