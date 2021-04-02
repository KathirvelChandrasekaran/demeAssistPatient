import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/models/user.dart';
import 'package:demeassist_patient/screens/home.dart';
import 'package:demeassist_patient/screens/startScreen.dart';
import 'package:demeassist_patient/service/geolocatorService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final geoService = GeolocatorService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    if (user == null)
      return StartScreen();
    else
      return Stack(
        children: [
          StreamBuilder<Position>(
            stream: geoService.getCurrentLocation(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text("");
              print("Lan " + snapshot.data.latitude.toString());
              print("Lon " + snapshot.data.longitude.toString());

              String uid = FirebaseAuth.instance.currentUser.uid;
              FirebaseFirestore.instance
                  .collection('LocationDetails')
                  .doc(uid)
                  .update({
                    'latitude': snapshot.data.latitude,
                    'longitude': snapshot.data.longitude,
                    'email': FirebaseAuth.instance.currentUser.email
                  })
                  .then((value) => print('Value is updated'))
                  .catchError((err) => print(err));
              print(snapshot.data);

              return Text("");
            },
          ),
          PatientHome(),
        ],
      );
  }
}
