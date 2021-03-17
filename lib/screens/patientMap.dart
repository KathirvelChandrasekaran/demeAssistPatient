import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/service/geolocatorService.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:demeassist_patient/models/user.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;

class PatientMap extends StatefulWidget {
  final Position initialPosition;
  double homeLat, homeLng;
  PatientMap({this.initialPosition, this.homeLat, this.homeLng});
  @override
  _PatientMapState createState() => _PatientMapState();
}

class _PatientMapState extends State<PatientMap> {
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;
  BitmapDescriptor customIcon;

  String _placeDistance;
  double totalDistance = 0.0;

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    print("home lat lng " +
        widget.homeLat.toString() +
        widget.homeLng.toString());
    print("dest lat lng " +
        widget.initialPosition.latitude.toString() +
        " " +
        widget.initialPosition.longitude.toString());
    _addMarker(LatLng(widget.homeLat, widget.homeLng), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(
        LatLng(
            widget.initialPosition.latitude, widget.initialPosition.longitude),
        "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    getRequest(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.homeLat}, ${widget.homeLng}&destination=${widget.initialPosition.latitude}, ${widget.initialPosition.longitude}&key=AIzaSyBEOELGvFI8GJoiLzj3d6sGX_KqY1cJk48");
    _getPolyline();

    totalDistance += _coordinateDistance(
      widget.homeLat,
      widget.homeLng,
      widget.initialPosition.latitude,
      widget.initialPosition.longitude,
    );

// Storing the calculated total distance of the route
    setState(() {
      _placeDistance = totalDistance.toStringAsFixed(2);
      print('DISTANCE: $_placeDistance km');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryViolet,
        ),
        backgroundColor: Colors.white10,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "MAPS",
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
      ),
      body: StreamBuilder<Position>(
        stream: geoService.getCurrentLocation(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData)
          //   return Center(
          //     child: SpinKitCubeGrid(
          //       color: primaryViolet,
          //     ),
          //   );
          // else
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialPosition.latitude,
                  widget.initialPosition.longitude),
              zoom: 18.0,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
          ),
          FloatingActionButton(
            onPressed: () async {
              await saveCurrentLocation(widget.initialPosition.latitude,
                  widget.initialPosition.longitude);
            },
            child: Icon(Icons.save_alt_rounded),
            backgroundColor: primaryViolet,
            tooltip: "Set Current Location as Home",
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: () => _launchURL(
                "google.navigation:q=${widget.homeLat},${widget.homeLng}"),
            backgroundColor: primaryViolet,
            child: Icon(Icons.directions_walk_outlined),
            tooltip: "Start direction",
          ),
        ],
      ),
    );
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _launchURL(String gMaps) async {
    await canLaunch(gMaps) ? await launch(gMaps) : throw "could not launch URL";
  }

  Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        String jData = response.body;
        var decodedData = jsonDecode(jData);
        print(decodedData);
      }
    } catch (e) {
      return "failed";
    }
  }

  _createMarker(double lat, double lng) {
    return <Marker>[
      Marker(
        markerId: MarkerId('patient'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Patient Home"),
      ),
    ].toSet();
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBEOELGvFI8GJoiLzj3d6sGX_KqY1cJk48",
      PointLatLng(widget.homeLat, widget.homeLng),
      PointLatLng(
          widget.initialPosition.latitude, widget.initialPosition.longitude),
      travelMode: TravelMode.walking,
    );
    print(result.points.toString());
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else
      print("null");

    _addPolyLine();
  }

  saveCurrentLocation(double lat, double lng) async {
    final coordinates = Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    String extractedAddress = '${first.addressLine} ';
    UserModel user = UserModel();
    user.address = extractedAddress;
    await FirebaseFirestore.instance
        .collection('LocationDetails')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
          'home': {'lat': lat, 'lng': lng, 'address': extractedAddress}
        })
        .then((value) => print("Home location is updated"))
        .catchError((err) => print('Error ' + err));
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
        ),
      ),
    );
  }
}