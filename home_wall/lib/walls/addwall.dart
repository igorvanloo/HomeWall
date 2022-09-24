// Flutter
import 'dart:io';
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_storage/firebase_storage.dart';

// others
import 'package:image_picker/image_picker.dart';

// Files
import 'package:home_wall/helper/userdata_service.dart';

class AddWallPage extends StatefulWidget {
  String? userId;

  AddWallPage({Key? key, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddWallPage();
}

class _AddWallPage extends State<AddWallPage> {
  File? _image;
  final imagePicker = ImagePicker();
  final TextEditingController wallNameController = TextEditingController();
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
        .child("${widget.userId}/climbing_walls")
        .child(wallNameController.text);
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();

    // Upload image to FireStore Database
    UserDataService().postWallsToFireStore(
        userId: widget.userId,
        wallName: wallNameController.text,
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
        title: const Text("Add new Wall"),
        backgroundColor: Colors.red,
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              children: [
                const Text("Upload Image"),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 350,
                  height: 60,
                  child: TextField(
                    controller: wallNameController,
                    decoration: const InputDecoration(
                        labelText: "Wall Name",
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
                            child: _image == null
                                ? const Center(child: Text("No image uploaded"))
                                : Image.file(_image!),
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
                                    if (wallNameController.text.isEmpty) {
                                      showSnackBar("Please choose a Wall Name",
                                          const Duration(seconds: 5));
                                    }
                                    if (_image == null) {
                                      showSnackBar("Please Select an Image",
                                          const Duration(seconds: 5));
                                    } else {
                                      uploadImage().whenComplete(() =>
                                          showSnackBar(
                                              "New wall Added Successfully",
                                              const Duration(seconds: 3)));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red),
                                  child: const Text("Upload Image"))
                            ],
                          )
                        ],
                      )),
                    ))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
