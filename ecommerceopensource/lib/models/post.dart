class Post{
  final String id;
  final String cat;
  final String name;
  final String image;
  final String desc;
  final int price;
  final int quant;
  // final String pais;

  const Post({
    required this.id,
    required this.cat,
    required this.name,
    required this.image,
    required this.desc,
    required this.price,
    required this.quant,
  });

  Post.fromJson(Map<String, Object?> json)
      : this(id: json['id']! as String,
    cat: json['cat']! as String,
    name: json['name']! as String,
    image: json['image']! as String,
    price: json['price']! as int,
    quant: json['quant']! as int,
    desc: json['desc']! as String,
  );

  Map<String,Object?> toJson() => {
    'id':id,
    'cat':cat,
    'name':name,
    'image':image,
    'price':price,
    'desc':desc,
    'quantity':quant,
  };
}