import 'dart:async';

import 'package:app1/utlis/colors.dart';
import 'package:app1/utlis/distance_calculations.dart';
import 'package:app1/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double lat = 0;
  double lng = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    determinePosition();

    setState(() {});
    Timer.periodic(const Duration(seconds: 10), (timer) {
      Geolocator.getCurrentPosition().then((position) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'lat': position.latitude,
          'lng': position.longitude,
        });

        setState(() {
          lat = position.latitude;
          lng = position.longitude;
        });
      }).catchError((error) {
        print('Error getting location: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: TextWidget(
            text: 'HOME',
            fontSize: 18,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .where('userType', isEqualTo: 'Student')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                  )),
                );
              }

              final data = snapshot.requireData;
              return ListView.separated(
                itemCount: data.docs.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: SizedBox(
                      width: 300,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_circle,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          TextWidget(
                            text: data.docs[index]['name'],
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                    ),
                    trailing: TextWidget(
                      text:
                          '${calculateDistance(lat, lng, data.docs[index]['lat'], data.docs[index]['lng']).toStringAsExponential(2)} km',
                      fontSize: 14,
                      fontFamily: 'Medium',
                    ),
                  );
                },
              );
            }));
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
