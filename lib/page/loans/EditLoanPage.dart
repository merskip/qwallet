import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../Currency.dart';
import '../../utils.dart';
import '../CurrencySelectionPage.dart';

class EditLoanPage extends StatelessWidget {
  final Reference<PrivateLoan> loanRef;

  const EditLoanPage({Key key, this.loanRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Edit loan"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SimpleStreamWidget(
            stream: DataSource.instance.getPrivateLoan(privateLoan: loanRef),
            builder: (context, loan) => _EditLoanForm(loan: loan),
          ),
        ),
      ),
    );
  }
}

class _EditLoanForm extends StatefulWidget {
  final PrivateLoan loan;

  const _EditLoanForm({Key key, this.loan}) : super(key: key);

  @override
  _EditLoanFormState createState() => _EditLoanFormState();
}

class _EditLoanFormState extends State<_EditLoanForm> {
  final _formKey = GlobalKey<FormState>();

  Currency currency;
  final amountTextController = TextEditingController();

  final titleTextController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date;

  @override
  void initState() {
    initFields();
    _configureDate();
    super.initState();
  }

  initFields() {
    currency = widget.loan.amount.currency;
    amountTextController.text = widget.loan.amount.amount.toStringAsFixed(2);
    titleTextController.text = widget.loan.title;
    date = widget.loan.date;
  }

  _configureDate() {
    dateController.text = getFormattedDate(date);

    dateFocus.addListener(() async {
      if (dateFocus.hasFocus) {
        final date = await showDatePicker(
          context: context,
          initialDate: this.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        dateFocus.nextFocus();
        if (date != null) {
          dateController.text = getFormattedDate(date);
          setState(() => this.date = date);
        }
      }
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat("d MMMM yyyy").format(date);
  }

  @override
  void dispose() {
    amountTextController.dispose();
    titleTextController.dispose();
    dateController.dispose();
    dateFocus.dispose();
    super.dispose();
  }

  void onSelectedCurrency(BuildContext context) async {
    final selectedCurrency = await pushPage(
      context,
      builder: (context) => CurrencySelectionPage(
        selectedCurrency: currency,
      ),
    );
    if (selectedCurrency != null) {
      setState(() => this.currency = selectedCurrency);
    }
  }

  void onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      DataSource.instance.updatePrivateLoan(
        loanRef: widget.loan.reference,
        amount: parseAmount(amountTextController.text),
        currency: currency,
        title: titleTextController.text.trim().nullIfEmpty(),
        date: date,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildBorrower(context),
        Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor),
        buildLender(context),
        Divider(),
        SizedBox(height: 16),
        buildAmount(context),
        SizedBox(height: 16),
        buildTitle(context),
        SizedBox(height: 16),
        buildDate(context),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildSubmitButton(context),
        )
      ]),
    );
  }

  Widget buildBorrower(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Borrower"),
      value: SimpleStreamWidget(
        stream: widget.loan.getBorrowerCommonName(context).asStream(),
        builder: (context, borrowerName) => Text(borrowerName),
      ),
    );
  }

  Widget buildLender(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Lender"),
      value: SimpleStreamWidget(
        stream: widget.loan.getLenderCommonName(context).asStream(),
        builder: (context, lenderName) => Text(lenderName),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      controller: amountTextController,
      decoration: InputDecoration(
        labelText: "#Amount",
        suffixIcon: FlatButton(
          child: Text(currency?.symbol),
          textColor: Theme.of(context).primaryColor,
          onPressed: () => onSelectedCurrency(context),
        ),
      ),
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      validator: (value) {
        final amount = parseAmount(value);
        if (amount == null) return "#Enter a amount";
        if (amount <= 0) return "#Amount must be greater then zero";
        return null;
      },
    );
  }

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      controller: titleTextController,
      decoration: InputDecoration(
        labelText: "#Title",
        isDense: true,
      ),
      validator: (value) {
        if (value.trim().isEmpty) return "#This field cannot be empty";
        return null;
      },
      maxLength: 50,
    );
  }

  Widget buildDate(BuildContext context) {
    return TextFormField(
      controller: dateController,
      focusNode: dateFocus,
      decoration: InputDecoration(
        labelText: "#Date",
        isDense: true,
      ),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text("#Save changes"),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}
