// Firebase related
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Internal Files
import 'package:home_wall/models/user_model.dart';
import 'package:home_wall/models/wall_model.dart';
import 'package:home_wall/models/route_model.dart';

class UserDataService {
  void postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    User? user = FirebaseAuth.instance.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
  }

  void postWallsToFireStore(
      {required userId, required wallName, required downloadURL}) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    WallModel wallModel = WallModel();

    wallModel.wallname = wallName;
    wallModel.downloadURL = downloadURL;

    await firebaseFirestore
        .collection("users")
        .doc(userId)
        .collection("walls")
        .doc(wallName)
        .set(wallModel.toMap());
  }

  void postRoutesToFireStore(
      {required userId,
      required wallName,
      required routeName,
      required routeGrade,
      required routeSent,
      required downloadURL}) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    RouteModel routeModel = RouteModel();

    routeModel.routename = routeName;
    routeModel.routegrade = routeGrade;
    routeModel.routesent = routeSent;
    routeModel.downloadURL = downloadURL;

    await firebaseFirestore
        .collection("users")
        .doc(userId)
        .collection("walls")
        .doc(wallName)
        .collection("routes")
        .doc(routeName)
        .set(routeModel.toMap());
  }

  Future<void> deleteFile(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print("Error deleting db from cloud: $e");
    }
  }
}
