import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Wallet.dart';

class BrowseAttachedFilesPage extends StatelessWidget {
  final Wallet wallet;

  const BrowseAttachedFilesPage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Browse attached files"),
      ),
    );
  }
}
