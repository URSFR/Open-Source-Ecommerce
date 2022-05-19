import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensource/Global/GlobalVar.dart';
import 'package:ecommerceopensource/provider/user_provider.dart';
import 'package:ecommerceopensource/screens/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  String _url = "https://rstpublicportfolio.web.app/#/";
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final webotpController = TextEditingController();
  bool canShow = false;
  var temp;

  FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
      await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if(authCredential.user != null){
        var userProvider = Provider.of<UserProvider>(context, listen: false);

        if(userProvider.ID==null || userProvider.ID==""){
          final FirebaseAuth auth = FirebaseAuth.instance;
          var document = FirebaseFirestore.instance.collection('Users').doc(auth.currentUser!.uid);
          document.get().then((document) async {

            userProvider.ID = document["ID"];
            userProvider.name = document["name"];
            userProvider.phone = document["phone"];
            userProvider.imgP = document["image"];
            userProvider.DNI = document["DNI"];
            userProvider.dinero = document["dinero"];
            userProvider.email = document["email"];
            userProvider.topay = document["topay"];
            userProvider.cartenabled=document["cartenabled"];
            userProvider.etime = document["etime"];
            userProvider.cstatus = document["cstatus"];
            userProvider.toquant = document["toquant"];

          }).whenComplete((){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));

          });
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));

        }

      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  getMobileFormWidget(context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: 75,),
                Container(
                  width: 45,
                  child: TextField(
                    maxLength: 11,
                    enabled: false,
                    decoration: InputDecoration(focusedBorder: OutlineInputBorder(),
                      hintText: "+54",
                      // labelText: "Numero de Telefono"
                    ),
                  ),
                ),
                Container(
                  width: 135,
                  child: TextField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "XX XXXX-XXXX",
                      // labelText: "Numero de Telefono"
                    ),
                  ),
                ),


              ],
            ),
            kIsWeb&&canShow?Container(width: 150, height: 150,child: TextField(controller: webotpController,decoration: InputDecoration(hintText: "OTP"))):SizedBox(),
            kIsWeb&&!canShow?buildSendOTPBtn("SEND OTP"):kIsWeb?buildSubmitBtn(userProvider,"ENTER"):!kIsWeb?FlatButton(
              onPressed: () async {
                setState(() {
                  showLoading = true;
                });

                // if(kIsWeb){
                // _auth.signInWithPhoneNumber(
                //     "+54"+phoneController.text,
                //     RecaptchaVerifier(
                //       container: 'recaptchaDOM',
                //       size: RecaptchaVerifierSize.compact,
                //       theme: RecaptchaVerifierTheme.dark,
                //     ));

                // }
                // else{
                await _auth.verifyPhoneNumber(
                  phoneNumber: "+54"+phoneController.text,
                  verificationCompleted: (phoneAuthCredential) async {
                    setState(() {
                      showLoading = false;
                    });
                    //signInWithPhoneAuthCredential(phoneAuthCredential);
                  },
                  verificationFailed: (verificationFailed) async {
                    setState(() {
                      showLoading = false;
                    });
                    _scaffoldKey.currentState!.showSnackBar(
                        SnackBar(content: Text(verificationFailed.message.toString())));
                  },
                  codeSent: (verificationId, resendingToken) async {
                    setState(() {
                      showLoading = false;
                      currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                      this.verificationId = verificationId;
                    });
                  },
                  codeAutoRetrievalTimeout: (verificationId) async {},
                );
                // }


              },
              child: Text("SEND"),
              color: Colors.blue,
              textColor: Colors.white,
            ):Container(),
            // SizedBox(height: 16,),

            // Spacer(),
            Container(
              width: 400,
              height: 400,
              child: Image.asset("assets/images/detuttionlinephot.jpeg"),
            ),
            GestureDetector(onTap: (){
              _launchURL();
            },child: Align(alignment: Alignment.bottomCenter,child: Text("Terms y Conditions"))),
          ],

        ),
      ),
    );
  }

  getOtpFormWidget(context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 15,),
            SizedBox(width: 75,),
            Container(
              child: TextField(
                controller: otpController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                ),
              ),
            ),
            SizedBox(height: 16,),
            FlatButton(
              onPressed: () async {

                PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId!, smsCode: otpController.text);
                UserCredential _authResult = await _auth.signInWithCredential(phoneAuthCredential);
                if(_authResult.additionalUserInfo!.isNewUser){
                 FirebaseFirestore.instance.collection("Users").doc(_authResult.user!.uid).set({
                    "ID": _authResult.user!.uid,
                    "name":"",
                    "phone":phoneController.text,
                    "image":"",
                    "DNI":"",
                    "dinero":0,
                    "email":"",
                     "topay":0,
                   "toquant":0,
                   "cartenabled":true,
                   "etime":0,
                   "cstatus":"Waiting",
                 }).whenComplete(() {
                    setState(() {
                      print("CREATING NEW USER");
                      signInWithPhoneAuthCredential(phoneAuthCredential);
                      // userProvider.ID = _authResult.user!.uid;
                      // userProvider.name = "";
                      // userProvider.phone = phoneController.text;
                      // userProvider.rating = 0;

                    });
                    DatabaseReference ref = FirebaseDatabase.instance.ref("Stats");
                    ref.update({
                      "accs":ServerValue.increment(1),
                    });
                  });
                }
                else{
                  signInWithPhoneAuthCredential(phoneAuthCredential);

                }

              },
              child: Text("VERIFY"),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            // Spacer(),
            Container(
              width: 400,
              height: 400,
              child: Image.asset("assets/images/detuttionlinephot.jpeg"),
            ),
            GestureDetector(onTap: (){
              _launchURL();
            },child: Align(alignment: Alignment.bottomCenter,child: Text("Térms and Conditions"))),
          ],
        ),
      ),
    );
  }

  Widget buildSendOTPBtn(String text) => ElevatedButton(
    onPressed: () async {
      setState(() {
        canShow = !canShow;
      });
      temp = await sendOTP(phoneController.text);

    },
    child: Text(text),
  );

  Widget buildSubmitBtn(UserProvider userProvider,String text) => ElevatedButton(
    onPressed: () {
      authenticateMe(temp, webotpController.text, userProvider, phoneController.text);
    },
    child: Text(text),
  );

  var document;
  sendOTP(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
      '+54'+phoneController.text,
    );
    printMessage("OTP Sent to +54 $phoneController.text");
    return confirmationResult;
  }
  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
  authenticateMe(ConfirmationResult confirmationResult, String otp, UserProvider userProvider, String phone) async {
    UserCredential userCredential = await confirmationResult.confirm(otp);
    userCredential.additionalUserInfo!.isNewUser
        ?FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.uid).set({
      "ID": userCredential.user!.uid,
      "name":"",
      "phone":phone,
      "image":"",
      "DNI":"",
      "dinero":0,
      "email":"",
      "topay":0,
      "cartenabled":true,
      "etime":0,
      "toquant":0,
      "cstatus":"Nothing",
    }).whenComplete(() {

    }): document = FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid);
    document.get().then((document) async {

      userProvider.ID = document["ID"];
      userProvider.name = document["name"];
      userProvider.phone = document["phone"];
      userProvider.imgP = document["image"];
      userProvider.DNI = document["DNI"];
      userProvider.dinero = document["dinero"];
      userProvider.email = document["email"];
      userProvider.topay = document["topay"];
      userProvider.toquant = document["toquant"];
      userProvider.cartenabled=document["cartenabled"];
      userProvider.etime = document["etime"];
      userProvider.cstatus = document["cstatus"];

    }).whenComplete((){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));

    });
  }

  printMessage(String msg) {
    debugPrint(msg);
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.ColorFondo,
        key: _scaffoldKey,
        body: Container(
          child: showLoading
              ? Center(
                  child: CircularProgressIndicator(),
          )
              : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
              ? getMobileFormWidget(context)
              : getOtpFormWidget(context),
          padding: const EdgeInsets.all(16),
        ));
  }
}