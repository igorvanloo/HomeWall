// Flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowRoutePage extends StatefulWidget {
  String? userId;
  String? wallName;
  String? routeName;
  String? routeGrade;
  String? routeSent;
  String? downloadURL;

  ShowRoutePage(
      {Key? key,
      this.userId,
      this.wallName,
      this.routeName,
      this.routeGrade,
      this.routeSent,
      this.downloadURL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShowRoutePage();
}

class _ShowRoutePage extends State<ShowRoutePage> {
  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final TextEditingController newGradeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${widget.routeName} - V${widget.routeGrade}'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Image.network(widget.downloadURL!),
              ),
              SizedBox(
                width: 350,
                height: 60,
                child: TextField(
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.userId)
                          .collection("walls")
                          .doc(widget.wallName)
                          .collection("routes")
                          .doc(widget.routeName)
                          .update({'routegrade': value});
                      showSnackBar("Route Grade updated to V$value",
                          const Duration(seconds: 3));
                    }
                  },
                  controller: newGradeController,
                  decoration: const InputDecoration(
                      labelText: "Update grade",
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
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.userId)
                        .collection("walls")
                        .doc(widget.wallName)
                        .collection("routes")
                        .doc(widget.routeName)
                        .update({'routesent': "1"});
                    showSnackBar("Route sent!", const Duration(seconds: 1));
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text('Sent'))
            ],
          )),
        ),
      ),
    );
  }
}
