import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/models/user.dart';
import 'package:demeassist_patient/service/geolocatorService.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapPatient extends StatefulWidget {
  final Position initialPosition;
  double homeLat, homeLng;
  MapPatient({this.initialPosition, this.homeLat, this.homeLng});
  @override
  _MapPatientState createState() => _MapPatientState();
}

class _MapPatientState extends State<MapPatient> {
  final GeolocatorService geoService = GeolocatorService();

  double homeLat, homeLng;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  @override
  void initState() {
    getHomeAddress();
    super.initState();
    print("home " + this.homeLat.toString());
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
          return MapboxMap(
            accessToken:
                'pk.eyJ1Ijoia2F0aGlydmVsY2hhbmRyYXNla2FyYW4iLCJhIjoiY2tsaXV5cXo0Mnc5MjJ2czg4a2VmNXh6NyJ9.9FQ2Ych6rlSv_twxlG1-7A',
            styleString:
                'mapbox://styles/kathirvelchandrasekaran/cklk8ip2k0exd17p32h58aoy9',
            initialCameraPosition: CameraPosition(
              zoom: 10.0,
              target: LatLng(widget.homeLat, widget.homeLng),
            ),
            compassEnabled: true,
            onMapCreated: (MapboxMapController controller) async {
              await controller.animateCamera(
                CameraUpdate.newLatLng(LatLng(widget.initialPosition.latitude,
                    widget.initialPosition.longitude)),
              );

              await controller.addCircle(
                CircleOptions(
                  circleRadius: 8.0,
                  circleColor: '#912f56',
                  circleOpacity: 0.8,
                  geometry: LatLng(widget.initialPosition.latitude,
                      widget.initialPosition.longitude),
                  draggable: false,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await saveCurrentLocation(widget.initialPosition.latitude,
              widget.initialPosition.longitude);
        },
        child: Icon(Icons.location_pin),
        backgroundColor: primaryViolet,
        tooltip: "Set Current Location as Home",
      ),
    );
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

  getHomeAddress() async {
    await FirebaseFirestore.instance
        .collection('LocationDetails')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        print("home lat " + value.data()['home']['lat'].toString());
        this.homeLng = value.data()['home']['lng'];
      });
    });
  }
}
