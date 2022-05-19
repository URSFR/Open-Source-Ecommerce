import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceopensource/Global/GlobalVar.dart';
import 'package:ecommerceopensource/models/post.dart';
import 'package:ecommerceopensource/screens/HomeScreen.dart';
import 'package:ecommerceopensource/screens/PostDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutterfire_ui/firestore.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textPriceController = TextEditingController();
  TextEditingController _textProvController = TextEditingController();
 bool _absorbing =false;
  @override
  Widget build(BuildContext context) {

    // var firestore = FirebaseFirestore.instance.collection("Products").where("cat",isEqualTo: GlobalChoose.categorychoosed).where("quant", isGreaterThanOrEqualTo: 1).get();
    final queryPostSolo = FirebaseFirestore.instance.collection("Products").where("quant", isGreaterThanOrEqualTo: 1).orderBy("quant").withConverter<Post>(fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!), toFirestore: (post,_) => post.toJson());
    final queryPostConPrice = FirebaseFirestore.instance.collection("Products").where("cat",isEqualTo: GlobalChoose.categorychoosed).where("quant", isGreaterThanOrEqualTo: 1).orderBy("quant").orderBy("price", descending: GlobalChoose.pricechoosed=="Highest"?true:false).withConverter<Post>(fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!), toFirestore: (post,_) => post.toJson());

    return Scaffold(
      backgroundColor: GlobalColors.ColorFondo,
      // appBar: AppBar(
      //   title:  Container(
      //   alignment: Alignment.centerLeft,
      //   color: Colors.white,
      //   // child: CategoryPicker(),
      // ),
      //   leading: IconButton(
      //     icon: Icon(Icons.search),
      //     onPressed: () {
      //       print("XD");
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        child: AbsorbPointer(
          absorbing: _absorbing,
          child:Center(
            child: Column(
              children: [
                SizedBox(height: 5,),
                Container(
                  width: 200,
                  child: TypeAheadFormField(
                    suggestionsCallback: (pattern) => GlobalList.category_list.where((item) => item.toString().toLowerCase().contains(pattern.toString().toLowerCase())),
                    itemBuilder: (_,String item)=>Container(color: GlobalColors.ColorFondo,child: ListTile(title: Text(item),)),
                    onSuggestionSelected: (String val){

                      _textEditingController.text=val;
                      GlobalChoose.categorychoosed=val;
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
                      decoration: InputDecoration(hintText: "What category are you searching?",border: OutlineInputBorder(),isDense: true,contentPadding: EdgeInsets.all(8)),
                      controller: _textEditingController,
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  child: TypeAheadFormField(
                    suggestionsCallback: (pattern) => GlobalList.price_list.where((item) => item.toString().toLowerCase().contains(pattern.toString().toLowerCase())),
                    itemBuilder: (_,String item)=>Container(color: GlobalColors.ColorFondo,child: ListTile(title: Text(item),)),
                    onSuggestionSelected: (String val){
                      _textPriceController.text=val;


                    },
                    getImmediateSuggestions: true,
                    hideSuggestionsOnKeyboardHide: false,
                    hideOnEmpty: false,
                    noItemsFoundBuilder: (context)=>Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Not range found"),
                    ),
                    textFieldConfiguration: TextFieldConfiguration(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(hintText: "Order by price",border: OutlineInputBorder(),isDense: true,contentPadding: EdgeInsets.all(8)),
                      controller: _textPriceController,
                    ),
                  ),
                ),
                ElevatedButton(onPressed: (){
                  if(_textProvController.text!=""&&_textPriceController.text!=""){
                    if(_textPriceController.text=="Highest Price"){
                      GlobalChoose.pricechoosed= "Highest";
                    }else if(_textPriceController.text=="Lowest Price"){
                      GlobalChoose.pricechoosed= "Lowest";
                    }
                  } else if(_textProvController.text==""&&_textPriceController.text!=""){
                    if(_textPriceController.text=="Highest Price"){
                      GlobalChoose.pricechoosed= "Highest";
                    }else if(_textPriceController.text=="Lowest Price"){
                      GlobalChoose.pricechoosed= "Lowest";
                    }
                  }else if(_textProvController.text!=""&&_textPriceController.text==""){
                    GlobalChoose.pricechoosed="";
                  }else{
                    GlobalChoose.pricechoosed="";
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
                }, child: Text("SEARCH")),
                SizedBox(height: 10,),
                Container(
                  width: 145,
                  height: MediaQuery.of(context).size.width,
                  child: FirestoreQueryBuilder<Post>(pageSize: 2,query:
                  GlobalChoose.pricechoosed!=""?queryPostConPrice:
                          queryPostSolo,
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(name: post.name,image: post.image,price: post.price, id: post.id,description: post.desc,category: post.cat,quantity: post.quant)));
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(height: 150,width: 150,child: Image.network(post.image)),
                                    Text(post.name),
                                    Text(post.price.toString()+" \$"),
                                  ],
                                ),
                              ),
                            );
                        }

                    );
                  }
                  ),
                )
              ],
            ),
          ),

        ),
      ),
    );

  }

}