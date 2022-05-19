import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensource/Global/GlobalVar.dart';
import 'package:ecommerceopensource/provider/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  bool _absorbing=false;
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerDNI = TextEditingController();
  var firestore = FirebaseFirestore.instance;

  var bytes;
  var logoBase64;
  bool? imageselected=false;
  FilePickerResult? pickedFile;

  void chooseImage() async {
    pickedFile = await FilePicker.platform.pickFiles(withData: true,allowCompression:true);
    if (pickedFile != null) {
      print(pickedFile);
      try {
        setState(() {
          logoBase64 = pickedFile!.files.first.bytes;
          imageselected=true;


        });
      } catch (err) {
        print(err);
      }
    } else {
      print('No Image Selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: GlobalColors.ColorFondo,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(onPressed: (){
            if(userProvider.dinero==0){
              showDialog(context: context, builder: (context)=>AlertDialog(
                title: Text("Remove account"),
                content: Column(children: [
                  Text("If there is any pending order, it will wait for it to be completed."),
                  Text(" "),
                  Text("This action is irreversible and all your data will be deleted."),
                ],),
                actions: [
                  TextButton(onPressed: () {
                    DatabaseReference ref = FirebaseDatabase.instance.ref("AccDelete/${auth.currentUser!.uid}");
                    ref.set({
                      "num":userProvider.phone,
                      "id":auth.currentUser!.uid,
                      "time":ServerValue.timestamp,
                    }).whenComplete(() {
                      EasyLoading.showError("You requested account delete");
                      setState(() {
                        userProvider.dinero=0;
                        _absorbing=false;
                      });
                    });
                  },
                      child: Text("Request Account Delete")),
                  TextButton(onPressed: ()=>          Navigator.of(context, rootNavigator: true).pop('dialog'),
                      child: Text("Close"))],
              ));
            }else{
              Fluttertoast.showToast(msg: "ERROR, YOU MUST NOT HAVE MONEY");
            }
          }, child: Text("Request Account Delete",style: TextStyle(fontSize: 10),)),
        ),
        backgroundColor: GlobalColors.ColorTab,
      ),
      body: AbsorbPointer(
        absorbing: _absorbing,
        child: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 45,),

                  GestureDetector(
                    onTap: (){
                      chooseImage();
                    },
                    child:
                    userProvider.imgP!=""&&userProvider.imgP!=null?Container(width: 150,height: 150,child: CircleAvatar(backgroundImage: NetworkImage(userProvider.imgP!)))
                        :logoBase64!=null?Container(width: 150,height: 150,
                      child: CircleAvatar(backgroundImage: MemoryImage(logoBase64),
                      ),
                    ):Container(width: 150,height: 150,child: CircleAvatar(backgroundImage: AssetImage("assets/images/SampleUser.png"),)),
                  ),
                  SizedBox(height: 30,),
                  Container(width:100,child: TextField(textAlign: TextAlign.center,maxLength: 30,decoration: InputDecoration(hintText: "Name"),controller: _controllerName,)),
                  SizedBox(height: 30,),
                  Container(width:250,child: TextFormField(textAlign: TextAlign.center,validator: ValidationBuilder().email().maxLength(50).build(),decoration: InputDecoration(hintText: "Email"),controller: _controllerEmail,)),
                  SizedBox(height: 30,),
                  Container(width:100,child: TextField(textAlign: TextAlign.center,maxLength: 8,keyboardType: TextInputType.number,decoration: InputDecoration(hintText: "DNI"),controller: _controllerDNI,)),
                  SizedBox(height: 30,),
                  SizedBox(height: 30,),
                  // Container(width:100,child: TextField(decoration: InputDecoration(hintText: "Email"),)),
                  // SizedBox(height: 30,),
                  // Container(width:100,child: TextField(decoration: InputDecoration(hintText: "Nombre"),)),
                  // SizedBox(height: 30,),
                  ElevatedButton(onPressed: () async {
                    EasyLoading.show(status: "LOADING");
                    setState(() {
                      _absorbing=true;
                    });
                    if (logoBase64 != null) {
                      // var result = await FlutterImageCompress.compressWithList(
                      //   logoBase64,
                      //   minHeight: 1920,
                      //   minWidth: 1080,
                      //   quality: 10,
                      //   rotate: 135,
                      // );
                      // print(result.length);

                      var wedansendesamba = FirebaseStorage.instance.ref('Users/${auth.currentUser!.uid}');
                      wedansendesamba.putData(logoBase64).whenComplete(() async {
                        String url = await wedansendesamba.getDownloadURL();

                        firestore.collection("Users").doc(auth.currentUser!.uid).update({
                          if(_controllerName.text!="")"name":_controllerName.text,
                          if(_controllerDNI.text!="")"DNI":_controllerDNI.text,
                          if(_controllerEmail.text!="")"email":_controllerEmail.text,
                          "image":
                          url
                          // "gs://detuttionlinetest.appspot.com/Users/${auth.currentUser!.uid}"
                          ,

                        }).then((value) {
                          EasyLoading.showSuccess("SUCCESS");
                          setState(() {
                            setState(() {
                              userProvider.name = _controllerName.text;
                              userProvider.imgP = url;
                              userProvider.DNI = _controllerDNI.text;
                              userProvider.email = _controllerEmail.text;
                              _absorbing=false;
                            });
                            Navigator.pop(context);
                          });
                        });
                      });



                    }else if(_controllerEmail.text!=""&&_controllerEmail.text!=null||_controllerName.text!=""&&_controllerName.text!=null||_controllerDNI.text!=""&&_controllerDNI.text!=null){
                      firestore.collection("Users").doc(auth.currentUser!.uid).update({
                        if(_controllerName.text!="")"name":_controllerName.text,
                        if(_controllerDNI.text!="")"DNI":_controllerDNI.text,
                        if(_controllerEmail.text!="")"email":_controllerEmail.text,
                      }).then((value) {
                        EasyLoading.showSuccess("SUCCESS");
                        setState(() {
                          setState(() {
                            userProvider.name = _controllerName.text;
                            userProvider.DNI = _controllerDNI.text;
                            userProvider.email = _controllerEmail.text;
                            _absorbing=false;
                          });
                          Navigator.pop(context);

                        });
                      });
                    }else{
                      EasyLoading.showError("NOTHING TO UPDATE");
                      setState(() {
                        _absorbing=false;
                      });

                    }


                  }, child: Text("DONE"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
