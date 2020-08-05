import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/page/CurrencySelectionPage.dart';
import 'package:qwallet/page/UserChoicePage.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/UserAvatar.dart';

class LoanForm extends StatefulWidget {
  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();

  List<User> users;

  final lenderTextController = TextEditingController();
  final lenderFocus = FocusNode();
  User lenderUser;

  final borrowerTextController = TextEditingController();
  final borrowerFocus = FocusNode();
  User borrowerUser;

  String personsValidationMessage;

  Currency currency;
  final amountTextController = TextEditingController();

  final titleTextController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date = getDateWithoutTime(DateTime.now());

  @override
  void initState() {
    initUsers();
    initCurrency();
    _configureDate();
    _formatUserCommonName(
      lenderTextController,
      lenderFocus,
      () => lenderUser,
    );
    _formatUserCommonName(
      borrowerTextController,
      borrowerFocus,
      () => borrowerUser,
    );
    super.initState();
  }

  initUsers() async {
    final users = await FirebaseService.instance.fetchUsers();
    setState(() => this.users = users);
  }

  initCurrency() {
    final currentLocale = Intl.getCurrentLocale();

    currency = Currency.all
        .firstWhere((currency) => currency.locales.contains(currentLocale));
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

  void _formatUserCommonName(
    TextEditingController controller,
    FocusNode focusNode,
    User getUser(),
  ) {
    focusNode.addListener(() {
      final user = getUser();
      if (!focusNode.hasFocus && user != null) {
        controller.text = user.getCommonName(null);
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
    setState(() => personsValidationMessage = null);
    if (_formKey.currentState.validate() && _validPersons()) {
      DataSource.instance.addPrivateLoan(
        lenderUid: lenderUser?.uid,
        lenderName: lenderUser == null ? lenderTextController.text : null,
        borrowerUid: borrowerUser?.uid,
        borrowerName: borrowerUser == null ? borrowerTextController.text : null,
        amount: parseAmount(amountTextController.text),
        currency: currency,
        title: titleTextController.text.trim().nullIfEmpty(),
        date: date,
      );
      Navigator.of(context).pop();
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
        buildLenderField(context),
        SizedBox(height: 16),
        Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor),
        SizedBox(height: 16),
        buildBorrowerField(context),
        if (personsValidationMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              personsValidationMessage,
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
          ),
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
        )
      ]),
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
            user.getCommonName(context).toLowerCase() == text.toLowerCase(),
        orElse: () => null,
      );

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
      child: Text("#Add loan"),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}
