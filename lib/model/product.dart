import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String description;
  final String symbol;

  final DocumentSnapshot snapshot;

  Product({this.name, this.description, this.symbol, this.snapshot});

  factory Product.from(DocumentSnapshot snapshot) => Product(
        name: snapshot.data['name'],
        description: snapshot.data['description'],
        symbol: snapshot.data['symbol'],
        snapshot: snapshot,
      );
}
