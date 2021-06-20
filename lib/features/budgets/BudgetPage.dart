import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/Wallet.dart';

class BudgetPage extends StatelessWidget {
  final Wallet wallet;
  final Budget budget;

  const BudgetPage({
    Key? key,
    required this.wallet,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
