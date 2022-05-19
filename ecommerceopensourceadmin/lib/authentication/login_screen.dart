import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          SizedBox(height: 75,),
          Container(width: 400,child: TextField(controller: _emailcontroller,decoration: InputDecoration(hintText: "Email"),),),
          Container(width: 400,child: TextField(controller: _passwordcontroller,decoration: InputDecoration(hintText: "Password"),),),
          SizedBox(height: 15,),
          ElevatedButton(onPressed: (){
            signIn();
          }, child: Text("Enter"))
        ],)
      ),
    );
  }

  Future signIn()async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailcontroller.text.trim(), password: _passwordcontroller.text.trim());
  }
}
