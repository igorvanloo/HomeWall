// Flutter
import 'dart:ui';

import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:home_wall/helper/userdata_service.dart';

// Files
import 'package:home_wall/walls/addroutes.dart';
import 'package:home_wall/models/user_model.dart';
import 'package:home_wall/walls/showroute.dart';

class RoutesPage extends StatefulWidget {
  String? wallName;
  String? wallURL;

  RoutesPage({Key? key, this.wallName, this.wallURL}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesPage();
}

class _RoutesPage extends State<RoutesPage> {
  // Get User ID to load correct wall pages
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Routes for ${widget.wallName}'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(loggedInUser.uid)
              .collection("walls")
              .doc(widget.wallName)
              .collection("routes")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Loading Routes'),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No Routes have been added yet'),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  String routeName = snapshot.data!.docs[index]['routename'];
                  String routeGrade = snapshot.data!.docs[index]['routegrade'];
                  String routeSent = snapshot.data!.docs[index]['routesent'];
                  String url = snapshot.data!.docs[index]['downloadURL'];
                  return Slidable(
                    endActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        onPressed: (context) {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(loggedInUser.uid)
                              .collection("walls")
                              .doc(widget.wallName)
                              .collection("routes")
                              .doc(routeName)
                              .update({'routesent': "1"});
                        },
                        icon: Icons.business,
                        label: "Sent",
                        backgroundColor: Colors.yellow,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(loggedInUser.uid)
                              .collection("walls")
                              .doc(widget.wallName)
                              .collection("routes")
                              .doc(routeName)
                              .delete();
                          UserDataService().deleteFile(url);
                        },
                        icon: Icons.delete,
                        label: "Delete",
                        backgroundColor: Colors.red,
                      )
                    ]),
                    child: Column(
                      children: [
                        Card(
                          child: InkWell(
                            splashColor: Colors.red,
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ShowRoutePage(
                                              userId: loggedInUser.uid,
                                              wallName: widget.wallName,
                                              routeName: routeName,
                                              routeGrade: routeGrade,
                                              routeSent: routeSent,
                                              downloadURL: url,
                                            )));
                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      routeName,
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "V$routeGrade",
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    routeSentIcon(routeSent),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(color: Colors.red),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => AddRoutePage(
                                userId: loggedInUser.uid,
                                wallName: widget.wallName,
                                wallURL: widget.wallURL,
                              )));
                });
              },
              child: const Text('Add Route'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget routeSentIcon(routeSent) {
  if (routeSent == "1") {
    return const Icon(
      Icons.check,
      color: Colors.green,
    );
  } else {
    return const Icon(
      Icons.close,
      color: Colors.red,
    );
  }
}
