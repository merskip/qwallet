import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';

class AddCategoryPage extends StatelessWidget {

  final Reference<Wallet> walletRef;

  const AddCategoryPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add category"),
      ),
    );
  }
}
