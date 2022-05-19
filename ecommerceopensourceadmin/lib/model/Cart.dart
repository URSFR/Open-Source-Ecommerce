
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartModel{
  final String image;
  final String name;
  final int price;
  final int quant;
  final String id;
  final Timestamp time;

  const CartModel({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.quant,
    required this.time,
  });

  CartModel.fromJson(Map<String, Object?> json)
      : this(price: json['price']! as int,
    quant: json['quant']! as int,
    time: json['time']! as Timestamp,
    id: json['id']! as String,
    name: json['name']! as String,
    image: json['image']! as String,
  );

  Map<String,Object?> toJson() => {
    "id":id,
    "name":name,
    "image":image,
    'price':price,
    'quant':quant,
    "time":time,
  };
}