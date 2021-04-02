import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist_patient/models/user.dart';
import 'package:demeassist_patient/screens/mapWrapper.dart';
import 'package:demeassist_patient/screens/wrapper.dart';
import 'package:demeassist_patient/service/authService.dart';
import 'package:demeassist_patient/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PatientHome extends StatefulWidget {
  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  final AuthService authService = AuthService();
  String email = FirebaseAuth.instance.currentUser.email;
  String uid = FirebaseAuth.instance.currentUser.uid;
  UserModel user = UserModel();
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
          "HOME",
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Wrapper(),
                ),
              );
            },
            tooltip: "Logout",
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('PatientDetails')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot patientDetails = snapshot.data.documents[index];
              return Container(
                child: patientDetails.exists
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundImage: NetworkImage(
                                        patientDetails['imageURL']),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  Text(
                                    patientDetails['patientName'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 50),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Text(
                                    patientDetails['age'].toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Text(
                                    patientDetails['gender'].toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Text(
                                    patientDetails['mobile'].toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  FirebaseAuth
                                          .instance.currentUser.emailVerified
                                      ? Container(
                                          child: Text(
                                            'Email Verified',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.green),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ButtonTheme(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            child: RaisedButton.icon(
                                              icon: FaIcon(
                                                FontAwesomeIcons.telegram,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/resendMail');
                                              },
                                              label: Text(
                                                "Send another email",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                ),
                                              ),
                                              color: primaryViolet,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapWrapper(),
            ),
          );
        },
        backgroundColor: primaryViolet,
        child: FaIcon(FontAwesomeIcons.map),
      ),
    );
  }
}
