// Flutter
import 'dart:io';
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_storage/firebase_storage.dart';

// others
import 'package:image_picker/image_picker.dart';

// Files
import 'package:home_wall/helper/userdata_service.dart';

class AddRoutePage extends StatefulWidget {
  String? userId;
  String? wallName;

  AddRoutePage({Key? key, this.userId, this.wallName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddRoutePage();
}

class _AddRoutePage extends State<AddRoutePage> {
  final _offsets = <Offset>[];
  File? _image;
  final imagePicker = ImagePicker();
  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController routeGradeController = TextEditingController();
  String? downloadURL;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pick != null) {
        _image = File(pick.path);
      } else {
        showSnackBar("No file selected", const Duration(seconds: 3));
      }
    });
  }

  Future uploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}/${widget.wallName}")
        .child(routeNameController.text);
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();

    // Upload image to FireStore Database
    UserDataService().postRoutesToFireStore(
        userId: widget.userId,
        wallName: widget.wallName,
        routeName: routeNameController.text,
        routeGrade: routeGradeController.text,
        routeSent: "0",
        downloadURL: downloadURL);
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Add new Route"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 1000,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red)),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (details) => {
                                print(details.localPosition),
                                setState(() {
                                  _offsets.add(details.localPosition);
                                })
                              },
                              child: CustomPaint(
                                painter: MyCustomPainter(_offsets),
                                child: _image == null
                                    ? const Center(
                                        child: Text("No image uploaded"))
                                    : Image.file(_image!),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  imagePickerMethod();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                child: const Text("Select Image"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (routeNameController.text.isEmpty) {
                                      showSnackBar("Please choose a Route Name",
                                          const Duration(seconds: 5));
                                    }
                                    if (routeGradeController.text.isEmpty) {
                                      showSnackBar(
                                          "Please choose a Route grade",
                                          const Duration(seconds: 5));
                                    }
                                    if (_image == null) {
                                      showSnackBar("Please Select an Image",
                                          const Duration(seconds: 5));
                                    } else {
                                      uploadImage().whenComplete(() =>
                                          showSnackBar(
                                              "New Route Added Successfully",
                                              const Duration(seconds: 3)));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red),
                                  child: const Text("Add New Route"))
                            ],
                          )
                        ],
                      )),
                    )),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: 350,
                  height: 60,
                  child: TextField(
                    controller: routeNameController,
                    decoration: const InputDecoration(
                        labelText: "Route Name",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: 350,
                  height: 60,
                  child: TextField(
                    controller: routeGradeController,
                    decoration: const InputDecoration(
                        labelText: "Route Grade",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final offsets;

  MyCustomPainter(this.offsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var offset in offsets) {
      canvas.drawCircle(offset, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
