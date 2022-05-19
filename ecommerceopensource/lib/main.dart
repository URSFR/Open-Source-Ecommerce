import 'package:ecommerceopensource/authorization/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'provider/user_provider.dart';
import 'screens/HomeScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kIsWeb?await Firebase.initializeApp(options: FirebaseOptions(storageBucket: "",databaseURL: "",authDomain: "",apiKey: "", appId: "", messagingSenderId: "", projectId: "")):
  await Firebase.initializeApp();
  configLoading();
  runApp(MultiProvider(providers:[ ChangeNotifierProvider(
    create: (_)=> UserProvider(),),
  ],

    child: MaterialApp(home: MyApp(), builder: EasyLoading.init(),
    ),
  ),);
 
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  FirebaseAuth? _auth;

  User? _user;

  bool isLoading = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth!.currentUser;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {

    return isLoading ? Scaffold(
      body: Center(
        child: Container(
            child: CircularProgressIndicator()),
      ),
    ) : _user == null ? LoginScreen() : HomeScreen();
  }
}

