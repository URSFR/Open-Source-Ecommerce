import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';
// import 'package:uuid/uuid.dart';
import 'package:xid/xid.dart';

import '../Global/GlobalVar.dart';
import '../provider/user_provider.dart';

class PostDetailsScreen extends StatefulWidget {
  String name;
  String image;
  int price;
  String id;
  String category;
  String description;
  int quantity;
  PostDetailsScreen({Key? key, required this.name,required this.image, required this.price, required this.id,required this.category, required this.description,required this.quantity}) : super(key: key);

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}


class _PostDetailsScreenState extends State<PostDetailsScreen> {

  var valueText = "";
  TextEditingController _textFieldController = TextEditingController();
  var firestore = FirebaseFirestore.instance;
  bool _absorbing = false;
  int quantityprepared = 0;
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      backgroundColor: GlobalColors.ColorFondo,
      appBar: AppBar(
        backgroundColor: GlobalColors.ColorTab,
      ),
      body: AbsorbPointer(
        absorbing: _absorbing,
        child: SingleChildScrollView(
          child: Container(
            child: Column(children: [
              SizedBox(height: 5),

              Row(
                children: [
                  SizedBox(width: 5,),
                  Align(alignment: Alignment.centerLeft,child: Text(widget.category)),
                ],
              ),
              Center(child: Container(height: 200,width: 200,child: Image.network(widget.image))),
              SizedBox(height: 5,),
              Center(child: Text(widget.name,style: TextStyle(color: Colors.black,fontSize: 21),),),
              SizedBox(height: 3,),
              Center(child: Text("Price: "+widget.price.toString()+" USD",style: TextStyle(color: Colors.black,fontSize: 18),),),
              Center(child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(widget.description,style: TextStyle(color: Colors.black,fontSize: 16),),
              ),),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: widget.quantity>=1?StepperSwipe(
                  initialValue:0,
                  speedTransitionLimitCount: 15, //Trigger count for fast counting
                  onChanged: (int value) {
                    print(value);
                    setState(() {
                      quantityprepared=value;


                    });

                  },
                  firstIncrementDuration: Duration(milliseconds: 400), //Unit time before fast counting
                  secondIncrementDuration: Duration(milliseconds: 250), //Unit time during fast counting
                  direction: Axis.horizontal,
                  dragButtonColor: Colors.blueAccent,
                  maxValue: widget.quantity,
                  minValue: 1,
                  stepperValue: quantityprepared,
                  withFastCount: true,
                  withBackground: true,
                  iconsColor: Colors.grey,
                ):Container(
                  child: Text("Out of stock"),
                ),
              ),
              Center(child: ElevatedButton(onPressed: (){
                EasyLoading.show(status: "LOADING");
                setState(() {
                  _absorbing=true;
                });
                if(userProvider.cartenabled==true){
                  if(quantityprepared>=1){
                    var xid = Xid();

                    if(userProvider.name!=""&&userProvider!=null){
                      FirebaseFirestore.instance.collection("Users").doc(auth.currentUser!.uid).collection("Cart").doc(xid.toString()).set({
                        "id":xid.toString(),
                        "name":widget.name,
                        "price":widget.price*quantityprepared,
                        "quant":quantityprepared,
                        "image": widget.image,
                        "time":FieldValue.serverTimestamp(),
                      }).whenComplete(() {

                        FirebaseFirestore.instance.collection("Users").doc(auth.currentUser!.uid).update({
                          "topay": FieldValue.increment(widget.price*widget.quantity),
                          "toquant":FieldValue.increment(widget.quantity),
                        }).whenComplete(() {
                          Navigator.of(context, rootNavigator: true).pop('dialog');
                          EasyLoading.showSuccess("SUCCESS");
                          setState(() {
                            _absorbing=false;
                          });
                        });

                      });
                    }else{
                      EasyLoading.showError("ERROR: NO NAME");
                      setState(() {
                        _absorbing=false;
                      });
                    }

                  }else{
                    EasyLoading.showError("NO QUANTITY CHOOSED OR NOT STOCK AVAILABLE");
                    setState(() {
                      _absorbing=false;
                    });
                    // EasyLoading.showError("ERROR, NO SELECCIONÓ LA CANTIDAD O NO HAY STOCK");
                    // setState(() {
                    // _absorbing=false;
                    // Navigator.pop(context);
                    //
                    // });
                  }
                }else{
                  EasyLoading.showError("ERROR: WAITING FOR CART TO BE ENABLED");
                  setState(() {
                    _absorbing=false;
                  });
                }



              },child: Text("BUY"),),),
            ],),
          ),
        ),
      ),
    );
  }

}
