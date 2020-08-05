import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';
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
  User lenderUser;

  final borrowerTextController = TextEditingController();
  User borrowerUser;

  Currency currency;

  @override
  void initState() {
    initUsers();
    initCurrency();
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

  @override
  void dispose() {
    lenderTextController.dispose();
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
    // TODO: Impl
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
      user: borrowerUser,
      onSelectedUser: (user) => setState(() => this.borrowerUser = user),
    );
  }

  Widget buildUserTextField({
    BuildContext context,
    TextEditingController controller,
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
      onChanged: (value) {
        if (value != null) onSelectedUser(null);
      },
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
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
    );
  }

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "#Title",
        isDense: true,
      ),
      maxLength: 50,
    );
  }

  Widget buildDate(BuildContext context) {
    return TextFormField(
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
