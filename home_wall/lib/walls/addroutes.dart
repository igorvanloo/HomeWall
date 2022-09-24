// Flutter
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

// others
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

// Files
import 'package:home_wall/helper/userdata_service.dart';

class AddRoutePage extends StatefulWidget {
  String? userId;
  String? wallName;
  String? wallURL;

  AddRoutePage({Key? key, this.userId, this.wallName, this.wallURL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddRoutePage();
}

class _AddRoutePage extends State<AddRoutePage> {
  final _points = <List>[];
  File? _image;
  final imagePicker = ImagePicker();
  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController routeGradeController = TextEditingController();
  String? downloadURL;
  Color colour = Colors.black;
  static PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(recorder);

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
                                  _points.add([details.localPosition, colour]);
                                })
                              },
                              child: CustomPaint(
                                foregroundPainter:
                                    MyCustomPainter(_points, canvas),
                                child: Image.network(widget.wallURL!),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  colour = Colors.blue;
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                child: const Text("Holds"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  colour = Colors.yellow;
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.yellow),
                                child: const Text("Footholds"),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  colour = Colors.green;
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green),
                                child: const Text("Start holds"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  colour = Colors.red;
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                child: const Text("End Holds"),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _points.removeLast();
                                  },
                                  child: const Icon(Icons.undo)),
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
                ElevatedButton(
                    onPressed: () async {
                      Picture picture = recorder.endRecording();
                      final img = picture.toImage(300, 400);

                      if (routeNameController.text.isEmpty) {
                        showSnackBar("Please choose a Route Name",
                            const Duration(seconds: 5));
                      }
                      if (routeGradeController.text.isEmpty) {
                        showSnackBar("Please choose a Route grade",
                            const Duration(seconds: 5));
                      }
                      if (_image == null) {
                        showSnackBar("Please Select an Image",
                            const Duration(seconds: 5));
                      } else {
                        uploadImage().whenComplete(() => showSnackBar(
                            "New Route Added Successfully",
                            const Duration(seconds: 3)));
                      }
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    child: const Text("Add New Route"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final points;
  final canvas;
  MyCustomPainter(this.points, this.canvas) : super();

  @override
  void paint(canvas, Size size) {
    canvas.save();

    for (var point in points) {
      var offset = point[0];
      var colour = point[1];

      final Paint paint = Paint()..color = colour;
      canvas.drawCircle(offset, 3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
