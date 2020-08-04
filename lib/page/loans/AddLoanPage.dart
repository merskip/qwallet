import 'package:flutter/material.dart';
import 'package:qwallet/page/loans/LoanForm.dart';

class AddLoanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add loans"),
      ),
      body: LoanForm(),
    );
  }
}
