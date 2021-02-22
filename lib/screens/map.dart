import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/service/geolocatorService.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  final Position initialPosition;
  Map(this.initialPosition);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
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
          if (!snapshot.hasData)
            return Center(
              child: SpinKitCubeGrid(
                color: primaryViolet,
              ),
            );
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
          );
        },
      ),
    );
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
