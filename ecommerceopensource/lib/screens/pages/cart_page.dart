import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensource/Global/GlobalVar.dart';
import 'package:ecommerceopensource/models/cartModel.dart';
import 'package:ecommerceopensource/models/cartModel.dart';
import 'package:ecommerceopensource/models/cartModel.dart';
import 'package:ecommerceopensource/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:xid/xid.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  var valueText = "";
  TextEditingController _textFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;

    var firestore = FirebaseFirestore.instance.collection("Orders");
    final queryPost = FirebaseFirestore.instance.collection("Users").doc(auth.currentUser!.uid).collection("Cart").withConverter<CartModel>(fromFirestore: (snapshot, _) => CartModel.fromJson(snapshot.data()!), toFirestore: (post,_) => post.toJson());
    bool _absorbing=false;
    return Scaffold(
      bottomNavigationBar: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.green),onPressed: (){
        if(userProvider.cartenabled==true){
          _displayTextFieldInAD(context, auth, userProvider);

        }else{
          Fluttertoast.showToast(msg: "ERROR, ALREADY SUBMITTED THE ORDER");
        }
      }, child: userProvider.cartenabled==true?Text("Pay"):userProvider.cartenabled==false&&userProvider.cstatus=="Waiting"?Text("Waiting order approvation"):userProvider.cartenabled==false&&userProvider.cstatus=="Shipped"?Text("Order Shipped with an estimated wait of ${userProvider.etime} minutes"):userProvider.cartenabled==false&&userProvider.cstatus=="Arrived"?Text("ARRIVED"):Text("ERROR")),
      backgroundColor: GlobalColors.ColorFondo,
      appBar: AppBar(
        backgroundColor: GlobalColors.ColorTab,
      ),
      body: AbsorbPointer(
        absorbing: _absorbing,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 450,
                  width: 350,
                  child: FirestoreQueryBuilder<CartModel>(pageSize: 5,query: queryPost, builder: (context,snapshot,_){
                    return ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 20,
                          left: 15,
                          right: 15,
                        ),
                        itemCount: snapshot.docs.length,
                        itemBuilder: (context,index){
                          final hasEndreached = snapshot.hasMore&&
                              index+1==snapshot.docs.length&&
                              !snapshot.isFetchingMore;
                          if(hasEndreached){
                            snapshot.fetchMore();
                            print("+");
                          }
                          // if(snapshot.isFetching){
                          //   return Center(child: CircularProgressIndicator());
                          // } else if(snapshot.hasError){
                          //   return Text("HUBO UN ERROR,${snapshot.error}");
                          // }
                          // else{
                          //
                          // }
                          final post = snapshot.docs[index].data();
                          DateTime date = DateTime.parse(post.time.toDate().toString());

                          // var datetime = new DateTime.fromMicrosecondsSinceEpoch(post.time);

                          return Container(
                            width: MediaQuery.of(context).size.height,
                            height: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Container(width: 150,height: 150,child: Image.network(post.image)),
                                Text("Name: "+post.name),
                                Text("Price: "+post.price.toString()+" \$"),
                                Text("Quantity: "+post.quant.toString()),
                                Text("Time date: "+date.toString()),
                                Center(
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,children: [
                                    userProvider.cartenabled==true?ElevatedButton(onPressed: (){
                                      EasyLoading.show(status: "LOADING");
                                      setState(() {
                                        _absorbing=true;
                                      });
                                      FirebaseFirestore.instance.collection("Users").doc(auth.currentUser!.uid).collection("Cart").doc(post.id).delete().whenComplete(() {
                                        EasyLoading.showSuccess("SUCCESS");
                                        setState(() {
                                          _absorbing=false;
                                        });
                                      });



                                    }, child: Text("Remove Element"),):Container(),

                                  ],),
                                )
                              ],
                            ),
                          );
                        });
                  }
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _displayTextFieldInAD(BuildContext context, FirebaseAuth auth , UserProvider userProvider) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Where will your order be sent?'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Address"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Send'),
                onPressed: () async {

                  if(_textFieldController.text!=""){
                    FirebaseFirestore.instance.collection("Orders").doc(auth.currentUser!.uid).set({
                    "buyername":userProvider.name,
                    "price":userProvider.topay,
                    "userid":auth.currentUser!.uid,
                    "time":FieldValue.serverTimestamp(),
                    "address":_textFieldController.text,
                      "status":"Waiting",
                    }).whenComplete(() {
                      DatabaseReference ref = FirebaseDatabase.instance.ref("Stats");
                      ref.update({
                        "orders":ServerValue.increment(1),
                      });
                      FirebaseFirestore.instance.collection("Users").doc(auth.currentUser!.uid).update({
                        "cartenabled":false,

                      }).whenComplete(() {
                        setState(() {
                          userProvider.cartenabled==false;
                        });
                        Navigator.of(context, rootNavigator: true).pop('dialog');

                      });
                      Fluttertoast.showToast(msg: "Your order has been submitted");
                    });

                  }
                  else{
                    Fluttertoast.showToast(msg: "Insert Address");
                  }


                },
              ),
            ],
          );
        });
  }

}
