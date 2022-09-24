// Flutter
import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Others
import 'package:flutter_slidable/flutter_slidable.dart';

// Files
import 'package:home_wall/walls/addwall.dart';
import 'package:home_wall/models/user_model.dart';
import 'package:home_wall/walls/routespage.dart';
import 'package:home_wall/helper/userdata_service.dart';

class WallPage extends StatefulWidget {
  const WallPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WallPage();
}

class _WallPage extends State<WallPage> {
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
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(loggedInUser.uid)
              .collection("walls")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Loading Walls'),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No Walls have been added yet'),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  String wallName = snapshot.data!.docs[index]['wallname'];
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
                              .doc(wallName)
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
                              // This function will open a list of routes based on the wall selected
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RoutesPage(
                                              wallName: wallName,
                                            )));
                              });
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    wallName,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Ink.image(
                                  image: NetworkImage(url),
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          height: 20,
                          thickness: 5,
                          color: Colors.red,
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
                          builder: (BuildContext context) =>
                              AddWallPage(userId: loggedInUser.uid)));
                });
              },
              child: const Text('Add Wall'),
            ),
          ],
        ),
      ),
    );
  }
}
