import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensource/Global/GlobalVar.dart';
import 'package:ecommerceopensource/authorization/login_screen.dart';
import 'package:ecommerceopensource/screens/ProfileScreen.dart';
import 'package:ecommerceopensource/screens/pages/cart_page.dart';
import 'package:ecommerceopensource/screens/pages/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../provider/user_provider.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
int _paginaactual= 0;

List<Widget> _paginas=[
  SearchPage(),
  CartPage(),

];

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    // TODO: implement initState

    final FirebaseAuth auth = FirebaseAuth.instance;
    if(userProvider.ID==null){

      var document = FirebaseFirestore.instance.collection('Users').doc(auth.currentUser!.uid);
      document.get().then((document) async {

        userProvider.ID = document["ID"];
        userProvider.name = document["name"];
        setState(() {
          userProvider.name = document["name"];
        });
        userProvider.phone = document["phone"];
        userProvider.imgP = document["image"];
        userProvider.DNI = document["DNI"];
        userProvider.dinero = document["dinero"];
        userProvider.email = document["email"];
        userProvider.topay = document["topay"];
        userProvider.cartenabled=document["cartenabled"];
        userProvider.etime = document["etime"];
        userProvider.toquant = document["toquant"];
        userProvider.cstatus = document["cstatus"];

      }).then((value){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));

      });
    }
    else{
      print("everythings done");
    }

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    var userProvider = Provider.of<UserProvider>(context);
    // return GestureDetector(onTap: (){
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => const SearchPage()));
    // },
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: ()async=> false,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: GlobalColors.ColorTab,
            ),
            drawer: Drawer(
              // Add a ListView to the drawer. This ensures the user can scroll
              // through the options in the drawer if there isn't enough vertical
              // space to fit everything.
              child: Container(
                color: GlobalColors.ColorFondo,
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: GlobalColors.ColorTab,
                      ),
                      child: Text(userProvider.name!=null?userProvider.name!:""),
                    ),
                    Container(
                      color: GlobalColors.ColorExtra,
                      child: ListTile(
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
                          // Navigator.pop(context);
                        },
                      ),
                    ),
                    // ListTile(
                    //   title: const Text('Carrito'),
                    //   onTap: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (context) => const CarritoScreen()));
                    //     // Navigator.pop(context);
                    //   },
                    // ),
                    Container(
                      color: GlobalColors.ColorTab,
                      child: ListTile(
                        title: const Text('Exit'),
                        onTap: () {
                          auth.signOut();
                          setState(() {
                            userProvider.name="";
                            userProvider.imgP="";
                            userProvider.ID="";
                            userProvider.phone="";
                            userProvider.dinero=0;
                            userProvider.email="";
                            userProvider.DNI="";
                            userProvider.cartenabled=true;
                            userProvider.cstatus="Nothing";
                            userProvider.etime=0;
                            userProvider.toquant=0;
                          });
                          // Update the state of the app.
                          // ...
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()));                  },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: _paginas[_paginaactual],
            bottomNavigationBar: BottomNavigationBar(
                backgroundColor: GlobalColors.ColorExtra,
                type: BottomNavigationBarType.fixed,
                currentIndex: _paginaactual, // Use this to update the Bar giving a position
                onTap: (index){
                  setState(() {
                    _paginaactual = index;

                  });
                  // print("Selected Index: $index");
                },
                items: [
                  BottomNavigationBarItem(label: 'BUY', icon: Icon(Icons.shopping_cart)),
                  BottomNavigationBarItem(label: 'CART', icon: Icon(Icons.shopping_cart)),
                  // BottomNavigationBarItem(label: ('Marketplace'), icon: Icon(Icons.store)),
                  // BottomNavigationBarItem(label: ('Inventory'), icon: Icon(Icons.inventory)),
                  // BottomNavigationBarItem(label: ('Profile'), icon: Icon(Icons.person)),
                  // BottomNavigationBarItem(label: ('Swap'), icon: Icon(Icons.swap_horiz)),
                ]
            )
        ),
      ),
    );
  }
}
