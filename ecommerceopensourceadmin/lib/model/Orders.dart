import 'package:cloud_firestore/cloud_firestore.dart';

class Orders{
  final String address;
  final String buyername;
  final String userid;
  final String status;
  final int price;
  final Timestamp time;

  const Orders({
    required this.address,
    required this.buyername,
    required this.userid,
    required this.status,
    required this.price,
    required this.time,
  });

  Orders.fromJson(Map<String, Object?> json)
      : this(address: json['address']! as String,
    buyername: json['buyername']! as String,
    userid: json['userid']! as String,
    price: json['price']! as int,
    time: json['time']! as Timestamp,
    status: json['status']! as String,
  );

  Map<String,Object?> toJson() => {
    'address':address,
    'name':buyername,
    'userid':userid,
    'price':price,
    'status':status,
    'time':time,
  };
}