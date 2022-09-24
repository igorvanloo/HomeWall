class WallModel {
  String? wallname;
  String? downloadURL;

  WallModel({this.wallname, this.downloadURL});

  // receiving data from server
  factory WallModel.fromMap(map) {
    return WallModel(
      wallname: map['wallname'],
      downloadURL: map['downloadURL'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'wallname': wallname,
      'downloadURL': downloadURL,
    };
  }
}
