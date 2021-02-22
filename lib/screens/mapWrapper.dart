import 'package:demeassist_patient/service/geolocatorService.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:demeassist_patient/screens/map.dart';

class MapWrapper extends StatefulWidget {
  @override
  _MapWrapperState createState() => _MapWrapperState();
}

class _MapWrapperState extends State<MapWrapper> {
  final geoService = GeolocatorService();

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => geoService.getInitialLocation(),
      child: Scaffold(
        body: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? Map(position)
                : Center(
                    child: SpinKitCubeGrid(
                      color: primaryViolet,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
