import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RemainderResult extends StatefulWidget {
  @override
  _RemainderResultState createState() => _RemainderResultState();
}

class _RemainderResultState extends State<RemainderResult> {
  String uid;

  List<dynamic> days;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('PatientDetails')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser.email)
        .get()
        .then(
          (value) => setState(
            () {
              uid = value.docs[0]['uid'];
            },
          ),
        );
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
          "Remainder Section".toUpperCase(),
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('MedicineRemainder')
            .doc(uid)
            .collection('Medicines')
            .where('email', isEqualTo: FirebaseAuth.instance.currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SpinKitCubeGrid(
                color: primaryViolet,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot remainderDetails =
                    snapshot.data.documents[index];
                // print(remainderDetails['remainder']);
                days = remainderDetails['days'];
                return Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          remainderDetails['name'],
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Text(
                          remainderDetails['dosage'],
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Text(
                          remainderDetails['takeMedicine'],
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              remainderDetails['time']['hr'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(":"),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              remainderDetails['time']['min'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Text(
                          remainderDetails['type'],
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...days
                                .map(
                                  (day) => Text(day + "\t"),
                                )
                                .toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
