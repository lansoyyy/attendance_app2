import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addUser(name, email, password, userType) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'email': email,
    'password': password,
    'dateTime': DateTime.now(),
    'userType': userType,
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'lat': 0,
    'lng': 0,
  };

  await docUser.set(json);
}
