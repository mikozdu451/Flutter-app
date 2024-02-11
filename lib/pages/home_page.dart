import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/auth.dart';
import 'dart:ui' as ui;

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
// }

Location location = Location();
LocationData? currentLocation;
LocationData? previousLocation;
Timer? timer;

// void main() async {
//   runApp(HomePage());
// }

// class HomePage extends StatelessWidget {
//   HomePage({required this.gameID, Key? key}) : super(key: key);
//   final String gameID;
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }

class MapSample extends StatefulWidget {
  final String gameID;
  const MapSample({required this.gameID, Key? key}) : super(key: key);
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    Navigator.pop(context);
    await Auth().signOut();
  }

  // Future<void> initPlatformState() async {
  //   // Configure BackgroundFetch.
  //   var status = await BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //         minimumFetchInterval: 15,
  //         forceAlarmManager: false,
  //         stopOnTerminate: false,
  //         startOnBoot: true,
  //         enableHeadless: true,
  //         requiresBatteryNotLow: false,
  //         requiresCharging: false,
  //         requiresStorageNotLow: false,
  //         requiresDeviceIdle: false,
  //         requiredNetworkType: NetworkType.NONE,
  //       ),
  //       _onBackgroundFetch,
  //       _onBackgroundFetchTimeout);
  //   // Schedule backgroundfetch for the 1st time it will execute with 1000ms delay.
  //   // where device must be powered (and delay will be throttled by the OS).
  //   BackgroundFetch.scheduleTask(TaskConfig(
  //       taskId: "com.dltlabs.task",
  //       delay: 1000,
  //       periodic: false,
  //       stopOnTerminate: false,
  //       enableHeadless: true));
  // }

  // void _onBackgroundFetchTimeout(String taskId) {
  //   BackgroundFetch.finish(taskId);
  // }

  // void _onBackgroundFetch(String taskId) async {
  //   if (taskId == '_getCurrentLocation') {
  //     print('[BackgroundFetch] Event received');
  //   }
  // }

  Widget _offsetPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '5';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Need info",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '6';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Need help",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '7';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Danger",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 3,
            onTap: _blockMap,
            child: Row(children: <Widget>[
              const Text(
                "Block map",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_mapBlock ? Icons.close : Icons.check)
            ]),
          ),
          PopupMenuItem(
            value: 4,
            onTap: _showLocation,
            child: Row(children: <Widget>[
              const Text(
                "Show location",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canShowLocation ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 5,
            onTap: () {
              Future.delayed(
                const Duration(seconds: 0),
                () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text("SOS"),
                      content: const Text(
                          "Are you sure you want to send an SOS? This will send a notification to all the players and mark your position on the map! Use only in emergencys!"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _sendSOS();
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ]),
                ),
              );
            },
            child: const Text(
              "SOS",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuItem(
            value: 6,
            onTap: () {
              Future.delayed(
                const Duration(seconds: 0),
                () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text("Sign out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            signOut();
                            Navigator.pop(context);
                          },
                          child: const Text('Sign out'),
                        ),
                      ]),
                ),
              );
            },
            child: const Text(
              "Sign out",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
        ],

        icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        iconSize: 70,

        // Container(
        //   height: double.infinity,
        //   width: double.infinity,
        //   decoration: const ShapeDecoration(
        //       color: Colors.blue,
        //       shape: StadiumBorder(
        //         side: const BorderSide(color: Colors.white, width: 2),
        //       )),
        //   //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
        // ),
        offset: Offset.fromDirection(0, 0).translate(0, -400),
      );

  Widget _offsetPopupOrg() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '5';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Need info",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '6';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Need help",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 1,
            onTap: () {
              markerInfo = '7';
              _canPlaceM();
            },
            child: Row(children: <Widget>[
              const Text(
                "Danger",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlaceMarker ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 2,
            onTap: _clearMarkerDB,
            child: const Text(
              "Clear points",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuItem(
            value: 3,
            onTap: _canPlaceP,
            enabled: teamName == "org",
            child: Row(children: <Widget>[
              const Text(
                "Add polygon",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_canPlacePolygon ? Icons.check : Icons.close)
            ]),
          ),
          PopupMenuItem(
            value: 4,
            enabled: teamName == "org",
            onTap: _clearPolygon,
            child: const Text(
              "Clear polygons",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuItem(
            value: 5,
            onTap: _blockMap,
            enabled: teamName == "org",
            child: Row(children: <Widget>[
              const Text(
                "Block map",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(_mapBlock ? Icons.close : Icons.check)
            ]),
          ),
          PopupMenuItem(
            value: 7,
            onTap: () {
              Future.delayed(
                const Duration(seconds: 0),
                () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text("SOS"),
                      content: const Text(
                          "Are you sure you want to send an SOS? This will send a notification to all the players and mark your position on the map! Use only in emergencys!"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _sendSOS();
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ]),
                ),
              );
            },
            child: const Text(
              "SOS",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuItem(
            value: 8,
            onTap: _clearSOSDB,
            child: Row(children: const <Widget>[
              Text(
                "Clear SOS",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ]),
          ),
          PopupMenuItem(
            value: 9,
            enabled: teamName == "org",
            onTap: () {
              Future.delayed(
                const Duration(seconds: 0),
                () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text("Sign out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            signOut();
                            Navigator.pop(context);
                          },
                          child: const Text('Sign out'),
                        ),
                      ]),
                ),
              );
            },
            child: const Text(
              "Sign out",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
        ],

        icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        iconSize: 70,

        // Container(
        //   height: double.infinity,
        //   width: double.infinity,
        //   decoration: const ShapeDecoration(
        //       color: Colors.blue,
        //       shape: StadiumBorder(
        //         side: const BorderSide(color: Colors.white, width: 2),
        //       )),
        //   //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
        // ),
        offset: Offset.fromDirection(0, 0).translate(0, -500),
      );

  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();

  Set<Marker> _locations = Set<Marker>();
  Set<Marker> _locationMarkers = Set<Marker>();
  Set<Marker> _SOSMarkers = Set<Marker>();
  Set<Marker> _warningMarkers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> _polygonLatLng = <LatLng>[];
  var _canPlacePolygon = false;
  var _canPlaceMarker = false;
  var _mapBlock = true;
  var _canShowLocation = true;
  var teamName = "";
  var teamColor;
  var _isInsidePolygon = true;
  final _playerName = TextEditingController();
  final _teamName = TextEditingController();
  final _teamPassword = TextEditingController();
  var _role = "1";
  var markerInfo = "";

  Uint8List? markerImage;

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  int _polygonIdCounter = 1;
  int _markerIdCounter = 1;
  static const LatLng _center =
      const LatLng(52.232179694191174, 21.007067883345037);
  LatLng _lastMapPosition = _center;

  FirebaseFirestore db = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  void _addLocationDB() async {
    var pos = await location.getLocation();
    GeoFirePoint point =
        geo.point(latitude: pos.latitude!, longitude: pos.longitude!);
    db
      ..collection('Games')
          .doc('Game${widget.gameID}')
          .collection('location-$teamName')
          .doc('Player-${user!.email.toString()}')
          .set({
        'position': point.data,
        'player-info': [_playerName.text, _teamName.text, _role]
      });
  }

  void _addMarkerDB(LatLng pointM, String markerID, String markerInfo) async {
    GeoFirePoint point =
        geo.point(latitude: pointM.latitude, longitude: pointM.longitude);
    db
      ..collection('Games')
          .doc('Game${widget.gameID}')
          .collection('marker-$teamName')
          .doc('marker-${_playerName.text}_${_markerIdCounter.toString()}')
          .set({
        'position': point.data,
        'id': markerID,
        'marker-info': markerInfo
      });
  }

  void _addSOSDB(String markerID) async {
    var pos = await location.getLocation();
    GeoFirePoint point =
        geo.point(latitude: pos.latitude!, longitude: pos.longitude!);
    db
      ..collection('Games')
          .doc('Game${widget.gameID}')
          .collection('SOS')
          .doc(
              'marker_${_playerName.text}_${_markerIdCounter.toString()}_${teamName}_${DateTime.now().toString()}')
          .set({'position': point.data, 'id': "SOS_${_playerName.text}"});
  }

  void _addPolygonDB() async {
    List ListToSend = [];
    for (var lat in _polygonLatLng) {
      ListToSend.add(lat.latitude.toString() + "|" + lat.longitude.toString());
    }
    db
      ..collection('Games')
          .doc('Game${widget.gameID}')
          .collection('polygon')
          .doc('polygon')
          .set({
        'polygon': ListToSend,
      });
  }

  void _getPlayersLocations(String color) async {
    var collection = FirebaseFirestore.instance
        .collection('Games/Game${widget.gameID}/location-$color');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      if (queryDocumentSnapshot.id != "Player-${user!.email.toString()}") {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        GeoPoint pos = data['position']['geopoint'];
        final Uint8List markerIcon = await getBytesFromAssets(
            "assets/${data['player-info'][2]}_$color.png", 100);
        LatLng point = LatLng(pos.latitude, pos.longitude);

        _locationMarkers.add(Marker(
            markerId: MarkerId(
                "${queryDocumentSnapshot.id.replaceAll('Player-', '')}_${color}_marker"),
            position: point,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
                title: "Player", snippet: "Name: ${data['player-info'][0]}")));
      }
    }
  }

  void _getMarkersLocations(String color) async {
    var collection = FirebaseFirestore.instance
        .collection('Games/Game${widget.gameID}/marker-$color');
    var querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        if (queryDocumentSnapshot.id != "Player-${user!.email.toString()}") {
          Map<String, dynamic> data = queryDocumentSnapshot.data();
          GeoPoint pos = data['position']['geopoint'];
          final Uint8List markerIcon = await getBytesFromAssets(
              "assets/${data['marker-info']}_$color.png", 100);
          LatLng point = LatLng(pos.latitude, pos.longitude);

          _warningMarkers.add(Marker(
              markerId: MarkerId(
                  queryDocumentSnapshot.id.replaceAll('markerPlayer-', '') +
                      "_" +
                      color +
                      "_marker"),
              position: point,
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow:
                  InfoWindow(title: "Player", snippet: "Name: ${data['id']}")));
        }
      }
    } else {
      _warningMarkers.clear();
    }
  }

  void _getSOS() async {
    var collection =
        FirebaseFirestore.instance.collection('Games/Game${widget.gameID}/SOS');
    var querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        GeoPoint pos = data['position']['geopoint'];
        final Uint8List markerIcon =
            await getBytesFromAssets("assets/sos.png", 100);
        LatLng point = LatLng(pos.latitude, pos.longitude);

        _SOSMarkers.add(Marker(
            markerId: MarkerId("SOS_${queryDocumentSnapshot.id.split(' ')[0]}"),
            position: point,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
                title: "Player",
                snippet: "Time: ${queryDocumentSnapshot.id.split(' ')[1]}")));
      }
    } else {
      _SOSMarkers.clear();
    }
  }

  void _clearSOSDB() async {
    var collection =
        FirebaseFirestore.instance.collection('Games/Game${widget.gameID}/SOS');
    var querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        queryDocumentSnapshot.reference.delete();
      }
    }
  }

  void _clearMarkerDB() async {
    var collection = FirebaseFirestore.instance
        .collection('Games/Game${widget.gameID}/marker-blue');
    var querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        queryDocumentSnapshot.reference.delete();
      }
    }
    collection = FirebaseFirestore.instance
        .collection('Games/Game${widget.gameID}/marker-red');
    querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        queryDocumentSnapshot.reference.delete();
      }
    }
  }

  void _getPolygon() async {
    List listToMap = [];
    var collection = FirebaseFirestore.instance
        .collection('Games/Game${widget.gameID}/polygon');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      if (queryDocumentSnapshot.id == "polygon") {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        listToMap = data["polygon"];
        for (var loc in listToMap) {
          _polygonLatLng.add(LatLng(double.parse(loc.toString().split('|')[0]),
              double.parse(loc.toString().split('|')[1])));
        }
        _setPolygon();
      }
    }
  }

  bool _checkIfValidLocation(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * 1000 * asin(sqrt(a));
  }

  void _checkIfInsidePolygon(LocationData loc) {
    if (_isInsidePolygon == true) {
      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('GameZone'),
          points: _polygonLatLng,
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.05),
        ),
      );
      _isInsidePolygon = false;
    } else {
      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('GameZone'),
          points: _polygonLatLng,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.2),
        ),
      );
      _isInsidePolygon = true;
    }
    setState(() {});
    return;
  }

  Future<void> _getCurrentLocation() async {
    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      previousLocation = currentLocation;
      currentLocation = newLoc;
      // if (_mapBlock) {
      //   googleMapController
      //       .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      //           zoom:
      //           target: LatLng(
      //             newLoc.latitude!,
      //             newLoc.longitude!,
      //           ))));
      // }
      if (_polygons.isNotEmpty &&
          _canPlacePolygon == false &&
          _checkIfValidLocation(
                  LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  _polygonLatLng) ==
              _isInsidePolygon) {
        _checkIfInsidePolygon(currentLocation!);
      }
      if (teamName != "blue") {
        _getPlayersLocations("red");
        _getMarkersLocations("red");
      }
      if (teamName != "red") {
        _getPlayersLocations("blue");
        _getMarkersLocations("blue");
      }

      _getSOS();
      _locations = Set.from(_locationMarkers)
        ..addAll(_SOSMarkers)
        ..addAll(_warningMarkers);
      var distance = calculateDistance(
          currentLocation!.latitude,
          currentLocation!.longitude,
          previousLocation!.latitude,
          previousLocation!.longitude);
      if (distance > 8) {
        _addLocationDB();
      }
      setState(() {});
    });
  }

  void _setMarker(LatLng point) async {
    final String markerIdVal =
        'Player-${_playerName.text} Marker-$_markerIdCounter';

    _locations.add(
      Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(teamColor)),
    );

    _addMarkerDB(point, markerIdVal, markerInfo);

    _markerIdCounter++;
    setState(() {});
    _canPlaceMarker = false;
  }

  void _clearMarker() {
    _canPlaceMarker = false;
    Set<Marker> list = Set<Marker>();
    for (var m in _locations) {
      if (m.markerId.value.contains('location')) {
        list.add(m);
      }
    }
    _locations = list;
    setState(() {});
  }

  void _canPlaceP() {
    if (_canPlacePolygon) {
      _canPlacePolygon = false;
      _addPolygonDB();
      return;
    }
    _canPlacePolygon = true;
    _canPlaceMarker = false;
  }

  void _canPlaceM() {
    if (_canPlaceMarker) {
      _canPlaceMarker = false;
      return;
    }
    _canPlaceMarker = true;
    _canPlacePolygon = false;
  }

  void _showLocation() {
    if (_canShowLocation) {
      _canShowLocation = false;
      return;
    }
    _canShowLocation = true;
    _addLocationDB();
  }

  void _sendSOS() async {
    setState(() {});
    _addSOSDB("SOS");
  }

  void _setPolygon() {
    _polygons.add(
      Polygon(
        polygonId: const PolygonId('GameZone'),
        points: _polygonLatLng,
        strokeWidth: 4,
        fillColor: Colors.green.withOpacity(0.05),
      ),
    );
  }

  void _clearPolygon() {
    _canPlacePolygon = false;
    setState(() {
      _polygons.clear();
      _polygonLatLng.clear();
      _polygonIdCounter = 1;
    });
  }

  void _blockMap() {
    setState(() {
      if (_mapBlock) {
        _mapBlock = false;
        return;
      }
      _mapBlock = true;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<String> _checkPassword() async {
    var collection = FirebaseFirestore.instance.collection('Games');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      if (queryDocumentSnapshot.id == "Game${widget.gameID}") {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        if (_teamPassword.text == data['PasswordBlue']) {
          return Future.value("blue");
        } else if (_teamPassword.text == data['PasswordRed']) {
          return Future.value("red");
        } else if (_teamPassword.text == data['PasswordOrg']) {
          return Future.value("org");
        }
      }
    }
    return Future.value("Error");
  }

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: currentLocation == null || teamName.toString().isEmpty
            ? Scaffold(
                appBar: AppBar(
                  title: const Text("Player information"),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: "Name/Nick:"),
                      controller: _playerName,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "Group:"),
                      controller: _teamName,
                    ),
                    DropdownButton(
                      value: _role,
                      items: [
                        DropdownMenuItem(
                          child: Text("Soldier"),
                          value: '1',
                        ),
                        DropdownMenuItem(
                          child: Text("Sniper"),
                          value: '2',
                        ),
                        DropdownMenuItem(
                          child: Text("Support"),
                          value: '3',
                        ),
                        DropdownMenuItem(
                          child: Text("Medic"),
                          value: '4',
                        )
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _role = newValue!;
                        });
                      },
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: "Team password:"),
                      controller: _teamPassword,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var checkcode = await _checkPassword();
                          if (checkcode == "Error") {
                          } else if (checkcode == "blue") {
                            teamName = "blue";
                            teamColor = BitmapDescriptor.hueBlue;
                            setState(() {});
                          } else if (checkcode == "red") {
                            teamName = "red";
                            teamColor = BitmapDescriptor.hueRed;
                            setState(() {});
                          } else if (checkcode == "org") {
                            teamName = "org";
                            teamColor = BitmapDescriptor.hueMagenta;
                            setState(() {});
                          }
                        },
                        child: const Text("Join game")),
                  ],
                ))
            : Stack(children: [
                GoogleMap(
                    mapType: MapType.satellite,
                    polygons: _polygons,
                    markers: _locations,
                    scrollGesturesEnabled: _mapBlock,
                    zoomGesturesEnabled: _mapBlock,
                    tiltGesturesEnabled: _mapBlock,
                    rotateGesturesEnabled: _mapBlock,
                    zoomControlsEnabled: _mapBlock,
                    myLocationButtonEnabled: _mapBlock,
                    myLocationEnabled: _canShowLocation,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        zoom: 15),
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                      _getPolygon();
                      _getCurrentLocation();
                      _addLocationDB();
                    },
                    onCameraMove: _onCameraMove,
                    onTap: (point) {
                      if (_canPlacePolygon) {
                        setState(() {
                          _polygonLatLng.add(point);
                          _setPolygon();
                        });
                      }
                      if (_canPlaceMarker) {
                        setState(() {
                          _setMarker(point);
                        });
                      }
                    }),
                Align(
                  alignment: Alignment(-1, 0.9),
                  child: Container(
                    height: 80.0,
                    width: 80.0,
                    child:
                        teamName != "org" ? _offsetPopup() : _offsetPopupOrg(),
                  ),
                )
              ]));
  }
}
