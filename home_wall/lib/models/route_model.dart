class RouteModel {
  String? routename;
  String? routegrade;
  String? routesent;
  String? downloadURL;

  RouteModel(
      {this.routename, this.routegrade, this.routesent, this.downloadURL});

  // receiving data from server
  factory RouteModel.fromMap(map) {
    return RouteModel(
      routename: map['routegrade'],
      routegrade: map['routegrade'],
      routesent: map['routesent'],
      downloadURL: map['downloadURL'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'routename': routename,
      'routegrade': routegrade,
      'routesent': routesent,
      'downloadURL': downloadURL,
    };
  }
}
