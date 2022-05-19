import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:ecommerceopensourceadmin/global/global_vars.dart';
import 'package:ecommerceopensourceadmin/model/Orders.dart';
import 'package:ecommerceopensourceadmin/model/Products.dart';
import 'package:ecommerceopensourceadmin/screens/cart_products_screen.dart';
import 'package:ecommerceopensourceadmin/widgets/StatsWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:xid/xid.dart';

import '../authentication/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController page = PageController();
  final queryProducts = FirebaseFirestore.instance.collection("Products")
      .withConverter<Products>(
      fromFirestore: (snapshot, _) => Products.fromJson(snapshot.data()!),
      toFirestore: (post, _) => post.toJson());
  final queryOrders = FirebaseFirestore.instance.collection("Orders")
      .withConverter<Orders>(
      fromFirestore: (snapshot, _) => Orders.fromJson(snapshot.data()!),
      toFirestore: (post, _) => post.toJson());
  final queryProductsByCat = FirebaseFirestore.instance.collection("Products")
      .where("cat", isEqualTo: GlobalChoose.categorychoosed)
      .withConverter<Products>(
      fromFirestore: (snapshot, _) => Products.fromJson(snapshot.data()!),
      toFirestore: (post, _) => post.toJson());

  String categorychoose = "";
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerPrice = TextEditingController();
  TextEditingController _controllerDescription = TextEditingController();
  TextEditingController _controllerCategory = TextEditingController();
  TextEditingController _controllerQuantity = TextEditingController();
  TextEditingController _textEditingController = TextEditingController();

  var firestore = FirebaseFirestore.instance;

  var logoBase64;
  bool? imageselected = false;
  FilePickerResult? pickedFile;
  bool _absorbing = false;
  int Accounts = 0;
  int Ordrs = 0;
  int OrdrsC = 0;
  int Prods = 0;
  int TotalB = 0;

  final _database = FirebaseDatabase.instance.ref();
  var valueText = "";
  TextEditingController _textFieldController = TextEditingController();
  void activateListeners() {
    _database
        .child("Stats")
        .onValue
        .listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final accs = data["accs"] as int;
      final orders = data["orders"] as int;
      final ordersC = data["ordersC"] as int;
      final prods = data["prods"] as int;
      final totalB = data["totalB"] as int;
      setState(() {
        Accounts = accs;
        Ordrs = orders;
        OrdrsC = ordersC;
        Prods = prods;
        TotalB = totalB;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activateListeners();

  }

  void chooseImage() async {
    pickedFile = await FilePicker.platform.pickFiles(withData: true);
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
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.ColorExtra,
        title: Text("OSE Admin"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: page,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.blue[100],
              selectedColor: GlobalColors.ColorExtra,
              selectedTitleTextStyle: TextStyle(color: Colors.white),
              selectedIconColor: GlobalColors.ColorTab,
              backgroundColor: GlobalColors.ColorFondo,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10)),
              // ),
              // backgroundColor: Colors.blueGrey[700]
            ),
            title: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 150,
                    maxWidth: 150,
                  ),
                  // child: Image.asset(
                  //   'assets/images/ownimage',
                  // ),
                ),
                Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),
            // footer: Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     'mohada',
            //     style: TextStyle(fontSize: 15),
            //   ),
            // ),
            items: [
              SideMenuItem(
                priority: 0,
                title: 'Dashboard',
                onTap: () {
                  page.jumpToPage(0);
                },
                icon: Icon(Icons.home),
                // badgeContent: Text(
                //   '3',
                //   style: TextStyle(color: Colors.white),
                // ),
              ),
              SideMenuItem(
                priority: 1,
                title: 'Upload Product',
                onTap: () {
                  page.jumpToPage(1);
                },
                icon: Icon(Icons.add_circle),
              ),
              SideMenuItem(
                priority: 2,
                title: 'Products',
                onTap: () {
                  page.jumpToPage(2);
                },
                icon: Icon(Icons.list),
              ),
              SideMenuItem(
                priority: 3,
                title: 'Orders',
                onTap: () {
                  page.jumpToPage(3);
                },
                icon: Icon(Icons.assignment_turned_in),
              ),
              SideMenuItem(
                priority: 4,
                title: 'Account Deleting',
                onTap: () {
                  page.jumpToPage(4);
                },
                icon: Icon(Icons.remove),
              ),
              SideMenuItem(
                priority: 6,
                title: 'Exit',
                onTap: () async {
                  auth.signOut();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                icon: Icon(Icons.exit_to_app),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: page,
              children: [
                Container(color: Colors.blueGrey,child: Column(
                  children: [

                    Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatsWidget(title: "Accounts", stats: Accounts, icon: Icons.account_box,colorb: Colors.limeAccent,),
                        StatsWidget(title: "Orders", stats: Ordrs,icon: Icons.watch_later,colorb: Colors.brown,),
                        StatsWidget(title: "Products", stats: Prods, icon: Icons.production_quantity_limits,colorb: Colors.deepOrangeAccent,),
                      ],
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                      StatsWidget(title: "Orders Completed", stats: OrdrsC, icon: Icons.add_task,colorb: Colors.green,),
                      StatsWidget(title: "Total Benefits", stats: TotalB, icon: Icons.attach_money,colorb: Colors.green,),
                    ],)

                  ],
                ),),
                Container(color: Colors.blueGrey,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      SizedBox(height: 40,),
                      logoBase64==null?ElevatedButton(onPressed: (){
                        // print("LOGOBASE: "+logoBase64.toString());
                        chooseImage();

                      }, child: Text("Choose image")): Container(width: 200,height: 200,child: Image.memory(logoBase64)),
                      SizedBox(height: 20,),
                      Container(width: 150,child: TextFormField(controller: _controllerName,maxLength: 45,decoration: new InputDecoration(hintText: "Name",border: OutlineInputBorder(),isDense: true),)),
                      SizedBox(height: 20,),
                      Container(width: 150,child: TextField(controller: _controllerPrice,keyboardType: TextInputType.number,decoration: new InputDecoration(hintText: "Price",border: OutlineInputBorder(),isDense: true),)),
                      SizedBox(height: 20,),
                      Container(width: 150,child: TextField(controller: _controllerDescription,maxLength: 250,decoration: new InputDecoration(hintText: "Description",border: OutlineInputBorder(),isDense: true),)),
                      SizedBox(height: 20,),
                      Container(width: 150,child: TextField(controller: _controllerQuantity,maxLength: 10,keyboardType: TextInputType.number,decoration: new InputDecoration(hintText: "Quantity",border: OutlineInputBorder(),isDense: true),)),
                      SizedBox(height: 20,),
                      Container(
                        width: 250,
                        child: TypeAheadFormField(
                          suggestionsCallback: (pattern) => GlobalList.category_list.where((item) => item.toString().toLowerCase().contains(pattern.toString().toLowerCase())),
                          itemBuilder: (_,String item)=>Container(color: GlobalColors.ColorFondo,child: ListTile(title: Text(item),)),
                          onSuggestionSelected: (String val){
                            this._controllerCategory.text=val;
                            categorychoose=val;
                          },
                          getImmediateSuggestions: true,
                          hideSuggestionsOnKeyboardHide: false,
                          hideOnEmpty: false,
                          noItemsFoundBuilder: (context)=>Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Not categories found"),
                          ),
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(hintText: "Category",border: OutlineInputBorder(),),
                            controller: this._controllerCategory,
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),

                      ElevatedButton(onPressed: () async {
                        EasyLoading.show(status: "LOADING");
                        setState(() {
                          _absorbing=true;
                        });
                        var xid = Xid();

                        // Uuid uuid = Uuid();
                        // String vivon = uuid.v1();
                        if(int.parse(_controllerPrice.text)>=1 && int.parse(_controllerQuantity.text)>=1){
                            if(logoBase64!=null&&logoBase64!="null"&&_controllerQuantity!=""&&_controllerName.text!=""&&_controllerDescription.text!=""&&_controllerPrice.text!=""&&categorychoose!=""&&_controllerName.text!=null&&_controllerDescription.text!=null&&_controllerPrice.text!=null&&categorychoose!=null&&_controllerQuantity!=null){

                                var wedansendesamba = FirebaseStorage.instance.ref('Products/${xid.toString()}');
                                wedansendesamba.putData(logoBase64).whenComplete(() async {
                                  String url = await wedansendesamba.getDownloadURL();

                                  firestore.collection("Products").doc(xid.toString()).set({
                                    "name":_controllerName.text,
                                    "price":int.parse(_controllerPrice.text),
                                    "image":url,
                                    "desc": _controllerDescription.text,
                                    "cat":categorychoose,
                                    "quant":int.parse(_controllerQuantity.text),
                                    "id": xid.toString(),
                                  }).then((value) {
                                    DatabaseReference ref = FirebaseDatabase.instance.ref("Stats");
                                    ref.update({
                                      "prods":ServerValue.increment(1),
                                    });
                                    EasyLoading.showSuccess("SUCCESS");
                                    setState(() {
                                      _absorbing=false;
                                    });
                                  });
                                });

                            }
                            else{
                              EasyLoading.showError("CHECK THE FIELDS");
                              setState(() {
                                _absorbing=false;
                              });
                            }
                        } else{
                          EasyLoading.showError("CHECK IF YOUR PRODUCT IS WORTH MORE THAN 1 DOLLAR AND ITS QUANTITY ITS GREATER THAN 1");
                          setState(() {
                            _absorbing=false;
                          });
                        }


                      }, child: Text("DONE"))
                    ],),
                  ),
                ),
                Container(color: Colors.blueGrey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 25,),
                        Container(
                          width: 200,
                          child: TypeAheadFormField(
                            suggestionsCallback: (pattern) => GlobalList.category_list.where((item) => item.toString().toLowerCase().contains(pattern.toString().toLowerCase())),
                            itemBuilder: (_,String item)=>Container(color: GlobalColors.ColorFondo,child: ListTile(title: Text(item),)),
                            onSuggestionSelected: (String val){

                              _textEditingController.text=val;
                              GlobalChoose.categorychoosed=val;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

                            },
                            getImmediateSuggestions: true,
                            hideSuggestionsOnKeyboardHide: false,
                            hideOnEmpty: false,
                            noItemsFoundBuilder: (context)=>Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("no categories found"),
                            ),
                            textFieldConfiguration: TextFieldConfiguration(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(hintText: "Search category?",border: OutlineInputBorder(),isDense: true,contentPadding: EdgeInsets.all(8)),
                              controller: _textEditingController,
                            ),
                          ),
                        ),
                        Container(
                          width: 145,
                          height: MediaQuery.of(context).size.width,
                          child: FirestoreQueryBuilder<Products>(pageSize: 2,query: GlobalChoose.categorychoosed==""?queryProducts:queryProductsByCat,
                              builder: (context,snapshot,_){
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
                                      return
                                        GestureDetector(
                                          onTap: (){
                                            ADRP(context, post.id);
                                          },
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Container(height: 150,width: 150,child: Image.network(post.image)),
                                                Text(post.name),
                                                Text(" \$"+post.price.toString()),
                                              ],
                                            ),
                                          ),
                                        );
                                    }

                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(color: Colors.blueGrey,
                  width: 450,
                  height: MediaQuery.of(context).size.width,
                  child: FirestoreQueryBuilder<Orders>(pageSize: 2,query: queryOrders,
                      builder: (context,snapshot,_){
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

                              // var date = new DateTime.fromMicrosecondsSinceEpoch(post.time);

                              return Container(
                                color: Colors.white,
                                child: Column(children: [
                                  Text("Buyer Name: "+post.buyername),
                                  Text("Price: "+post.price.toString()),
                                  Text("User ID: "+post.userid),
                                  Text("Time: "+date.toString()),
                                  Text("Address: "+post.address),
                                  Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment:MainAxisAlignment.center,children: [
                                    ElevatedButton(onPressed: (){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: CartProductScreen(userid: post.userid,name: post.buyername,)));
                                    }, child: Text("Products"),),
                                    ElevatedButton(onPressed: (){
                                      if(post.status=="Waiting"){
                                        _displayTextFieldETIME(context, auth, post.userid);
                                      }
                                      else if(post.status=="Shipped"){
                                        FirebaseFirestore.instance.collection("Orders").doc(post.userid).update({
                                          "cstatus":"Arrived",
                                        });
                                        Fluttertoast.showToast(msg: "ARRIVED");
                                      }
                                      else if(post.status=="Arrived"){
                                        ADRemoveOrder(context, post.price,post.userid,false);
                                        Fluttertoast.showToast(msg: "REMOVED");

                                      }

                                    }, child: Text(post.status=="Waiting"?"Accept Order":post.status=="Shipped"?"Order Shipped":post.status=="Arrived"?"Order Arrived":"ERROR")),
                                    post.status=="Waiting"?ElevatedButton(onPressed: (){
                                      ADRemoveOrder(context, post.price,post.userid,true);

                                    }, child: Text("Cancel Order")):Container(),
                                  ],)
                                ],),
                              );
                            }

                        );
                      }
                  ),
                ),
                Container(
                  color: Colors.blueGrey,
                  child: Center(
                    child: Container(
                      width: 450,
                      height: MediaQuery.of(context).size.height * 0.79,
                      child: FirebaseAnimatedList(
                          query: FirebaseDatabase.instance
                              .ref().child("AccDelete")
                              // .orderByChild("completo")
                              ,
                          padding: new EdgeInsets.all(8.0),
                          reverse: false,
                          itemBuilder: (_, DataSnapshot snapshot,
                              Animation<double> animation, int x) {
                            String id = "";
                            int time = 0;
                            String num = "";

                            num = (snapshot.value as Map)["num"];
                            id = (snapshot.value as Map)["id"];
                            time = (snapshot.value as Map)["time"];

                            var date = new DateTime.fromMicrosecondsSinceEpoch(time);

                            return Container(
                              color: Colors.white,
                              child: Column(children: [
                                Text("Phone: "+num),
                                Text("ID: "+id),
                                Text("Time: "+date.toString()),
                                ElevatedButton(onPressed: (){
                                  ADEliminar(context, id);
                                }, child: Text("Delete"))
                              ],),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                // Container(
                //   color: Colors.white,
                //   child: Center(
                //     child: Text(
                //       'Download',
                //       style: TextStyle(fontSize: 35),
                //     ),
                //   ),
                // ),
                // Container(
                //   color: Colors.white,
                //   child: Center(
                //     child: Text(
                //       'Settings',
                //       style: TextStyle(fontSize: 35),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ADEliminar(BuildContext context, String id ) {
    // set up the buttons
    Widget ButtonYes = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        DatabaseReference ref = FirebaseDatabase.instance.ref("AccDelete/$id}");
        ref.remove();
        DatabaseReference ref2 = FirebaseDatabase.instance.ref("Stats");
        ref2.update({
          "accs":ServerValue.increment(-1),
        });
      },
    );
    Widget ButtonNo = TextButton(
      child: Text("No"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete the user?"),
      actions: [
        ButtonYes,
        ButtonNo,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ADRP(BuildContext context, String id ) {
    // set up the buttons
    Widget ButtonYes = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        FirebaseFirestore.instance.collection("Products").doc(id).delete();
        DatabaseReference ref2 = FirebaseDatabase.instance.ref("Stats");
        ref2.update({
          "prods":ServerValue.increment(-1),
        });
      },
    );
    Widget ButtonNo = TextButton(
      child: Text("No"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete the product?"),
      actions: [
        ButtonYes,
        ButtonNo,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ADRemoveOrder(BuildContext context, int price,String orderid, bool isCancel) {
    // set up the buttons
    Widget ButtonYes = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        if(isCancel==true){
          DatabaseReference ref = FirebaseDatabase.instance.ref("Stats");
          ref.update({
            "orders":ServerValue.increment(-1),
          });
          FirebaseFirestore.instance.collection("Orders").doc(orderid).delete();
          FirebaseFirestore.instance.collection("Users").doc(orderid).update({
            "cartenabled":true,
            "topay":0,
            "toquant":0,
            "cstatus":"Waiting",
            "etime":0,
          }).whenComplete(() {
            Navigator.of(context, rootNavigator: true).pop('dialog');

          });
        }
        else{
          DatabaseReference ref = FirebaseDatabase.instance.ref("Stats");
          ref.update({
            "orders":ServerValue.increment(-1),
            "ordersC":ServerValue.increment(1),
            "totalB":ServerValue.increment(price),
          });
          FirebaseFirestore.instance.collection("Orders").doc(orderid).delete();
          FirebaseFirestore.instance.collection("Users").doc(orderid).update({
            "cartenabled":true,
            "topay":0,
            "toquant":0,
            "cstatus":"Waiting",
            "etime":0,

          }).whenComplete(() {
            Navigator.of(context, rootNavigator: true).pop('dialog');

          });
        }


      },
    );
    Widget ButtonNo = TextButton(
      child: Text("No"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete the order?"),
      actions: [
        ButtonYes,
        ButtonNo,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _displayTextFieldETIME(BuildContext context, FirebaseAuth auth , String userid) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Estimated wait time'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              keyboardType: TextInputType.number,
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Wait time in minutes"),
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
                    FirebaseFirestore.instance.collection("Orders").doc(userid).update({
                      "cstatus":"Shipped",
                    }).whenComplete(() {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      Fluttertoast.showToast(msg: "SHIPPED");
                    });
                  }
                  else{
                    Fluttertoast.showToast(msg: "Insert wait time");
                  }


                },
              ),
            ],
          );
        });
  }

}

