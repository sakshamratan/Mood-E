import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.green),
                    padding:
                    MaterialStateProperty.all(const EdgeInsets.all(20)),
                    textStyle: MaterialStateProperty.all(const TextStyle(
                        fontSize: 14, color: Colors.white))),
                onPressed: () async {
                  selectImage();
                },
                child: const Text('Select')),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Future selectImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Select Image From !',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromGallery();
                            print('Image_Path:-');
                            print(selectedImagePath);
                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No Image Selected !"),
                              ));
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
                              )),
                        ),
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromCamera();
                            print('Image_Path:-');
                            print(selectedImagePath);

                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No Image Captured !"),
                              ));
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
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  selectImageFromGallery() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  //
  selectImageFromCamera() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }
}
decodeImage(Uint8List bytes) {
}

Future<String> _processImage(File imageFile) async {
  // Decode the image using the Image package
  final Uint8List bytes = await imageFile.readAsBytes();
  final image = decodeImage(bytes);

  // Resize the image to 224x224 using the Image package
  final resizedImage = copyResizeCropSquare(image, 224);

  // Save the resized image to a temporary file
  final tempDir = await getTemporaryDirectory();
  final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  File(tempPath).writeAsBytesSync((resizedImage));

  return tempPath;
}

copyResizeCropSquare(image, int i) {
}



Future selectImage(Null Function() param0) async {
  XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 10,
  );

  if (image != null) {
    File imageFile = File(image.path);
    String documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String imagePath = '$documentsDirectory/$fileName.jpg';

    try {
      // Copy the selected image to the app's documents directory
      await imageFile.copy(imagePath);
      selectImage(() {
        var selectedImagePath = imagePath;
      });
    } catch (e) {
      print(e);
    }
  }
}

