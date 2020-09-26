import 'package:flutter/material.dart';
import 'package:qwallet/page/loans/LoansPage.dart';

class RepaidLoanPage extends StatelessWidget {
  final LoansGroup loansGroup;

  const RepaidLoanPage({Key key, this.loansGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Mark as repaid loans"),
      ),
    );
  }
}
