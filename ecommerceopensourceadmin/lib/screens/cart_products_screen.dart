import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensourceadmin/model/Cart.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class CartProductScreen extends StatefulWidget {
  final userid;
  final name;
  const CartProductScreen({Key? key,this.name, this.userid}) : super(key: key);

  @override
  _CartProductScreenState createState() => _CartProductScreenState();
}

class _CartProductScreenState extends State<CartProductScreen> {


  @override
  Widget build(BuildContext context) {
    final queryCartProducts = FirebaseFirestore.instance.collection("Users").doc(widget.userid).collection("Cart").withConverter<CartModel>(fromFirestore: (snapshot, _) => CartModel.fromJson(snapshot.data()!), toFirestore: (post,_) => post.toJson());

    return Scaffold(
      body: SingleChildScrollView(child:
      Column(
        children: [
          Center(child: Container(child: Text(widget.name),),),
          Container(
            height: MediaQuery.of(context).size.width,
            child: FirestoreQueryBuilder<CartModel>(pageSize: 2,query: queryCartProducts,
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
                          Container(
                            child: Column(
                              children: [
                                Container(height: 150,width: 150,child: Image.network(post.image)),
                                Text("Name: "+post.name),
                                Text("Price: "+" \$"+post.price.toString()),
                                Text("Quantity: "+post.quant.toString()),
                              ],
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
    );
  }
}
