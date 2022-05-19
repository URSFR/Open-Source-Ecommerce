// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:detuttionlinecliente/global/global_var.dart';
// import 'package:detuttionlinecliente/provider/user_provider.dart';
// import 'package:detuttionlinecliente/screens/home.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
//
// class FirebaseAuthentication {
//   String phoneNumber = "";
//   var document;
//   sendOTP(String phoneNumber) async {
//     this.phoneNumber = phoneNumber;
//     FirebaseAuth auth = FirebaseAuth.instance;
//     ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
//       '+91 $phoneNumber',
//     );
//     printMessage("OTP Sent to +91 $phoneNumber");
//     return confirmationResult;
//   }
//
//   authenticateMe(ConfirmationResult confirmationResult, String otp, UserProvider userProvider, String phone) async {
//     UserCredential userCredential = await confirmationResult.confirm(otp);
//     userCredential.additionalUserInfo!.isNewUser
//         ?FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.uid).set({
//       "ID": userCredential.user!.uid,
//       "name":"",
//       "phone":phone,
//       "rating":0,
//       "image":"",
//       "DNI":"",
//       "lat":0.1,
//       "lng":0.1,
//       "dinero":0,
//       "email":"",
//       "cvu":"",
//       "tag":"Basico",
//     }).whenComplete(() {
//
//     }): document = FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid);
//     document.get().then((document) async {
//
//       userProvider.ID = document["ID"];
//       userProvider.name = document["name"];
//       userProvider.phone = document["phone"];
//       userProvider.rating = document["rating"];
//       userProvider.imgP = document["image"];
//       userProvider.DNI = document["DNI"];
//       userProvider.lat = document["lat"];
//       userProvider.lng = document["lng"];
//       userProvider.dinero = document["dinero"];
//       userProvider.email = document["email"];
//       userProvider.cvu = document["cvu"];
//       userProvider.tag = document["tag"];
//
//       if(userProvider.lat!=0.1&&userProvider.lng!=0.1){
//         List<Placemark> placemarks = await placemarkFromCoordinates(userProvider.lat!, userProvider.lng!);
//         GlobalChoose.PaisUser = placemarks[0].country!;
//
//       }
//
//     }).whenComplete((){
//       Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
//
//     });
//   }
//
//   printMessage(String msg) {
//     debugPrint(msg);
//   }
// }