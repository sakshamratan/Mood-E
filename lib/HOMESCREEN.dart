import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedImagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedImagePath == ''
                ? Image.asset(
              'assets/images/image_placeholder.png',
              height: 200,
              width: 200,
              fit: BoxFit.fill,
            )
                : Image.file(
              File(selectedImagePath),
              height: 200,
              width: 200,
              fit: BoxFit.fill,
            ),
            Text(
              'Select Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                textStyle: MaterialStateProperty.all(const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                )),
              ),
              onPressed: () {
                selectImage();
              },
              child: const Text('Select'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'Select Image From!',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          selectedImagePath = await selectImageFromGallery();
                          if (selectedImagePath != '') {
                            Navigator.pop(context);
                            navigateToNextPage(selectedImagePath);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("No Image Selected!"),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/gallery.png',
                                  height: 60,
                                  width: 60,
                                ),
                                Text('Gallery'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          selectedImagePath = await selectImageFromCamera();
                          if (selectedImagePath != '') {
                            Navigator.pop(context);
                            navigateToNextPage(selectedImagePath);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("No Image Captured!"),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/camera.png',
                                  height: 60,
                                  width: 60,
                                ),
                                Text('Camera'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> selectImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );

    if (pickedImage != null) {
      return pickedImage.path;
    } else {
      return '';
    }
  }

  Future<String> selectImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );

    if (pickedImage != null) {
      final imagePath = await copyImageToDocumentsDirectory(File(pickedImage.path));
      return imagePath;
    } else {
      return '';
    }
  }

  Future<String> copyImageToDocumentsDirectory(File imageFile) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final imagePath = '${documentsDirectory.path}/$fileName.jpg';

    try {
      await imageFile.copy(imagePath);
      return imagePath;
    } catch (e) {
      print(e);
      return '';
    }
  }

  void navigateToNextPage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(imagePath: imagePath),
      ),
    );
  }
}

class NextPage extends StatefulWidget {
  final String imagePath;

  const NextPage({required this.imagePath, Key? key}) : super(key: key);

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String output = '';
  bool isModelReady = false;
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
  }
// modellllllllllllllllllllllllll//
  void loadModel() async {
    var Tflite;
    await Tflite.loadModel(
      model: 'assets/labels/model.tflite',
      labels: 'assets/labels/labels.csv',
    );
    setState(() {
      isModelReady = true;
    });
  }

  Future<File> getFileFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/$assetPath');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  }

  void runModel() async {
    if (widget.imagePath.isNotEmpty && isModelReady) {
      final Uint8List imageBytes = await File(widget.imagePath).readAsBytes();
      var Tflite;
      var predictions = await Tflite.runModelOnImage(
        path: widget.imagePath,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
      );
      if (predictions != null && predictions.isNotEmpty) {
        setState(() {
          output = predictions[0]['label'];
        });
      }
    }
  }

  Uint8List preprocessImage(Uint8List imageBytes, List<int> inputShape) {
    // Perform any necessary preprocessing on the image bytes
    // Resize, normalize, etc.
    // Example preprocessing code:
    // ...

    // Return the preprocessed image as Uint8List
    return imageBytes;
  }

  String postprocessOutput(List<dynamic> output) {
    // Perform any necessary postprocessing on the model output
    // Convert logits to probabilities, apply thresholding, etc.
    // Example postprocessing code:
    // ...

    // Return the final label
    return 'Label';
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade800,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.yellow.shade800,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(
                File(widget.imagePath),
                height: 300,
                width: 300,
                fit: BoxFit.fill,
              ),
              ElevatedButton(
                onPressed: runModel,
                child: Text('GET MUSIC'),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.green),
                ),
              ),
              SizedBox(height: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: IconButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
