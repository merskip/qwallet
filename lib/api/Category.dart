import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';

import 'Converting.dart';

class FirebaseCategory extends FirebaseModel<FirebaseCategory>
    implements Category {
  final Identifier<Category> identifier;
  final String title;
  final IconData icon;
  final String? symbol = null;
  final Color primaryColor;
  final Color backgroundColor;
  final int order;

  String get titleText => Category.toTitleText(title);

  FirebaseCategory(DocumentSnapshot snapshot)
      : identifier = Identifier(domain: "firebase", id: snapshot.id),
        title = snapshot.getString("title")!,
        icon = snapshot.getIconData("icon")!,
        primaryColor = snapshot.getColorHex("primaryColor")!,
        backgroundColor = snapshot.getColorHex("backgroundColor")!,
        order = snapshot.getInt("order") ?? 0,
        super(snapshot);

  @override
  int compareTo(other) => Category.compareWithNullAtEnd(order, other.order);
}
