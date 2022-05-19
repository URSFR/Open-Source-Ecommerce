import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsWidget extends StatelessWidget {
  final title;
  final stats;
  final icon;
  final colorb;
  const StatsWidget({Key? key,required this.colorb,required this.stats,required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(children: [
          Container(decoration: BoxDecoration(color: Colors.white70,borderRadius: BorderRadius.all(Radius.circular(15)),border: Border.all(color: colorb,width: 5.0)),child: Column(
            children: [

              SizedBox(height: 10,),
              Row(
                children: [
                  Container(alignment: Alignment.center,width: 250,height: 75,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black,width:5))),child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [
                      Text(title,style: GoogleFonts.robotoCondensed(fontSize: 25)),
                      Icon(icon,color: colorb,),
                    ],
                  )),

                ],
              ),
              SizedBox(height: 15),
              Container(decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5))),child: Text(stats.toString(),style: GoogleFonts.playfairDisplay(fontSize: 35))),
              SizedBox(height: 15),
            ],
          ),)
        ],),
      ),
    );
  }
}
