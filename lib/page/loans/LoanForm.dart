import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SecondaryButton.dart';
import 'package:qwallet/widget/UserAvatar.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils.dart';
import '../CurrencySelectionPage.dart';
import '../UserChoicePage.dart';

class LoanForm extends StatefulWidget {
  final PrivateLoan initialLoan;

  final String submitText;
  final Function(
    BuildContext context,
    User lenderUser,
    String lenderName,
    User borrowerUser,
    String borrowerName,
    Money amount,
    String title,
    DateTime date,
  ) onSubmit;

  final String archiveText;
  final Function(BuildContext context) onArchive;

  const LoanForm({
    Key key,
    this.initialLoan,
    @required this.submitText,
    this.onSubmit,
    this.archiveText,
    this.onArchive,
  }) : super(key: key);

  @override
  LoanFormState createState() => LoanFormState();
}

class LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();

  List<User> users;

  final borrowerTextController = TextEditingController();
  final borrowerFocus = FocusNode();
  User borrowerUser;

  final lenderTextController = TextEditingController();
  final lenderFocus = FocusNode();
  User lenderUser;

  String personsValidationMessage;

  Currency currency;
  final amountTextController = TextEditingController();
  final titleTextController = TextEditingController();
  DateTime date;

  @override
  void initState() {
    initFields();
    _formatUserCommonName(
      borrowerTextController,
      borrowerFocus,
      () => borrowerUser,
    );
    _formatUserCommonName(
      lenderTextController,
      lenderFocus,
      () => lenderUser,
    );
    super.initState();
  }

  initFields() async {
    if (widget.initialLoan != null) {
      final loan = widget.initialLoan;

      amountTextController.text = loan.amount.amount.toString();
      currency = loan.amount.currency;
      titleTextController.text = loan.title;
      date = loan.date;

      final users = await DataSource.instance.getUsers();
      lenderUser = users.getByUid(loan.lenderUid);
      lenderTextController.text =
          lenderUser?.getCommonName(context) ?? loan.lenderName;

      borrowerUser = users.getByUid(loan.borrowerUid);
      borrowerTextController.text =
          borrowerUser?.getCommonName(context) ?? loan.borrowerName;
      setState(() => this.users = users);
    } else {
      final currentLocale = Intl.getCurrentLocale();
      currency = Currency.all
          .firstWhere((currency) => currency.locales.contains(currentLocale));
      date = getDateWithoutTime(DateTime.now());
    }
  }

  void _formatUserCommonName(
    TextEditingController controller,
    FocusNode focusNode,
    User getUser(),
  ) {
    focusNode.addListener(() {
      final user = getUser();
      if (!focusNode.hasFocus && user != null) {
        controller.text = user.getCommonName(context);
      }
    });
  }

  @override
  void dispose() {
    lenderTextController.dispose();
    lenderFocus.dispose();
    borrowerTextController.dispose();
    borrowerFocus.dispose();
    amountTextController.dispose();
    titleTextController.dispose();
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
    setState(() => personsValidationMessage = null);
    if (_formKey.currentState.validate() && _validPersons()) {
      widget.onSubmit(
        context,
        lenderUser,
        lenderUser == null ? lenderTextController.text : null,
        borrowerUser,
        borrowerUser == null ? borrowerTextController.text : null,
        Money(parseAmount(amountTextController.text), currency),
        titleTextController.text.trim().nullIfEmpty(),
        date,
      );
    }
  }

  bool _validPersons() {
    if (lenderUser != User.currentUser() &&
        borrowerUser != User.currentUser()) {
      setState(() => personsValidationMessage =
          "#You yourself must be lender or borrower");
      return false;
    }

    if (lenderUser == borrowerUser) {
      setState(() => personsValidationMessage =
          "#Lender and borrower cannot be the same person");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildBorrowerField(context),
        SizedBox(height: 16),
        Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor),
        SizedBox(height: 16),
        buildLenderField(context),
        if (personsValidationMessage != null) buildValidationMessage(context),
        SizedBox(height: 16),
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
        ),
        if (widget.onArchive != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 16),
            child: buildArchiveButton(context),
          )
      ]),
    );
  }

  Widget buildBorrowerField(BuildContext context) {
    return buildUserTextField(
      context: context,
      title: "#Borrower",
      selectTitle: "#Select borrower",
      controller: borrowerTextController,
      focusNode: borrowerFocus,
      user: borrowerUser,
      onSelectedUser: (user) => setState(() => this.borrowerUser = user),
    );
  }

  Widget buildLenderField(BuildContext context) {
    return buildUserTextField(
      context: context,
      title: "#Lender",
      selectTitle: "#Select lender",
      controller: lenderTextController,
      focusNode: lenderFocus,
      user: lenderUser,
      onSelectedUser: (user) => setState(() => this.lenderUser = user),
    );
  }

  Widget buildUserTextField({
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    String title,
    String selectTitle,
    User user,
    void onSelectedUser(User user),
  }) {
    final onSelectedSelectUser = () async {
      final selectedUser = await pushPage<User>(
        context,
        builder: (context) => UserChoicePage(
          title: selectTitle,
          selectedUser: user,
          allUsers: this.users,
        ),
      );
      if (selectedUser != null) {
        setState(() {
          controller.text = selectedUser.getCommonName(context);
          onSelectedUser(selectedUser);
        });
      }
    };

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: title,
        prefixIcon: user != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserAvatar(user: user),
              )
            : null,
        suffixIcon: IconButton(
          icon: Icon(Icons.person),
          onPressed: () => users != null ? onSelectedSelectUser() : null,
        ),
      ),
      onChanged: (text) {
        final matchedUser = getMatchedUser(text);
        if (user != matchedUser) onSelectedUser(matchedUser);
      },
      validator: (value) {
        if (value.trim().isEmpty) return "#This field cannot be empty";
        return null;
      },
    );
  }

  User getMatchedUser(String text) => users?.firstWhere(
        (user) =>
            user.getCommonName(context).toLowerCase() == text.toLowerCase() ||
            user.displayName.toLowerCase() == text.toLowerCase(),
        orElse: () => null,
      );

  Widget buildValidationMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        personsValidationMessage,
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      controller: amountTextController,
      decoration: InputDecoration(
        labelText: "#Amount",
        suffix: Text(currency.symbol),
        suffixIcon: IconButton(
          icon: Icon(Icons.edit),
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
      ),
      validator: (value) {
        if (value.trim().isEmpty) return "#This field cannot be empty";
        return null;
      },
      maxLength: 50,
    );
  }

  Widget buildDate(BuildContext context) {
    final locale = AppLocalizations.of(context).locale.toString();
    final date = this.date ?? DateTime.now();
    return DateTimeField(
      decoration: InputDecoration(
        labelText: "#Date",
        isDense: true,
      ),
      format: DateFormat("d MMMM yyyy", locale),
      initialValue: date,
      resetIcon: null,
      onShowPicker: (context, currentValue) => showDatePicker(
        context: context,
        initialDate: this.date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ),
      onChanged: (date) => setState(() => this.date = date),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(widget.submitText),
      onPressed: () => onSelectedSubmit(context),
    );
  }

  Widget buildArchiveButton(BuildContext context) {
    return SecondaryButton(
      child: Text(widget.archiveText),
      onPressed: () => widget.onArchive(context),
    );
  }
}
