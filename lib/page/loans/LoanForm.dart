import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/dialog/EnterMoneyDialog.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/UserAvatar.dart';

import '../../Money.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';
import '../UserChoicePage.dart';

class LoanForm extends StatefulWidget {
  final PrivateLoan? initialLoan;

  final String submitText;
  final Function(
    BuildContext context,
    User? lenderUser,
    String? lenderName,
    User? borrowerUser,
    String? borrowerName,
    Money amount,
    Money repaidAmount,
    String? title,
    DateTime date,
  ) onSubmit;

  const LoanForm({
    Key? key,
    this.initialLoan,
    required this.submitText,
    required this.onSubmit,
  }) : super(key: key);

  @override
  LoanFormState createState() => LoanFormState();
}

class LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();

  List<User>? users;

  final borrowerTextController = TextEditingController();
  final borrowerFocus = FocusNode();
  User? borrowerUser;

  final lenderTextController = TextEditingController();
  final lenderFocus = FocusNode();
  User? lenderUser;

  String? personsValidationMessage;

  final amountTextController = TextEditingController();
  final amountFocus = FocusNode();
  Money? amount;

  final repaidAmountTextController = TextEditingController();
  final repaidAmountFocus = FocusNode();
  late Money repaidAmount;

  final titleTextController = TextEditingController();

  late DateTime date;

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
    initAmountField(
      focusNode: amountFocus,
      controller: amountTextController,
      isCurrencySelectable: true,
      getValue: () => this.amount,
      onEnter: (amount) => setState(() {
        this.amount = amount;
        this.repaidAmount = Money(repaidAmount.amount, amount.currency);
      }),
    );

    initAmountField(
      focusNode: repaidAmountFocus,
      controller: repaidAmountTextController,
      isCurrencySelectable: false,
      getValue: () => this.repaidAmount,
      onEnter: (amount) => setState(() => this.repaidAmount = amount),
    );

    if (widget.initialLoan != null) {
      final loan = widget.initialLoan!;

      amountTextController.text = loan.amount.formattedOnlyAmount;
      amount = loan.amount;

      repaidAmountTextController.text = loan.repaidAmount.formattedOnlyAmount;
      repaidAmount = loan.repaidAmount;

      titleTextController.text = loan.title;
      date = loan.date;

      final users = await DataSource.instance.getUsers();
      lenderUser = loan.lenderUser;
      lenderTextController.text = loan.getLenderCommonName(context);

      borrowerUser = loan.borrowerUser;
      borrowerTextController.text = loan.getBorrowerCommonName(context);
      setState(() => this.users = users);
    } else {
      final currency = Currency.getDefaultBasedOnLocale();
      amount = Money(0, currency);
      repaidAmount = Money(0, currency);
      repaidAmountTextController.text = repaidAmount.formattedOnlyAmount;
      date = getDateWithoutTime(DateTime.now());

      final users = await DataSource.instance.getUsers();
      setState(() => this.users = users);
    }
  }

  void initAmountField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required bool isCurrencySelectable,
    required Money? getValue(),
    required void onEnter(Money money),
  }) {
    focusNode.addListener(() async {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        final initialMoney = getValue();
        final money = await showDialog(
          context: context,
          builder: (context) => EnterMoneyDialog(
            initialMoney: initialMoney!,
            currency: initialMoney!.currency,
            isCurrencySelectable: isCurrencySelectable,
          ),
        ) as Money?;
        if (money != null) {
          controller.text = money.formattedOnlyAmount;
          onEnter(money);
        }
      }
    });
  }

  void _formatUserCommonName(
    TextEditingController controller,
    FocusNode focusNode,
    User? getUser(),
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
    amountFocus.dispose();
    repaidAmountTextController.dispose();
    repaidAmountFocus.dispose();
    titleTextController.dispose();
    super.dispose();
  }

  void onSelectedSubmit(BuildContext context) async {
    setState(() => personsValidationMessage = null);
    if (_formKey.currentState!.validate() && _validPersons()) {
      widget.onSubmit(
        context,
        lenderUser,
        lenderUser == null
            ? lenderTextController.text.trim().nullIfEmpty()
            : null,
        borrowerUser,
        borrowerUser == null
            ? borrowerTextController.text.trim().nullIfEmpty()
            : null,
        amount!,
        repaidAmount,
        titleTextController.text.trim().nullIfEmpty(),
        date,
      );
    }
  }

  bool _validPersons() {
    if (lenderUser != User.currentUser() &&
        borrowerUser != User.currentUser()) {
      setState(() => personsValidationMessage = AppLocalizations.of(context)
          .privateLoanValidationCurrentUserIsNotLenderOrBorrower);
      return false;
    }

    if (lenderUser == borrowerUser) {
      setState(() => personsValidationMessage = AppLocalizations.of(context)
          .privateLoanValidationLenderAnBorrowerIsTheSamePerson);
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
        buildRepaidAmount(context),
        buildRemainingAmount(context),
        Divider(),
        SizedBox(height: 16),
        buildTitle(context),
        SizedBox(height: 16),
        buildDate(context),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildSubmitButton(context),
        ),
      ]),
    );
  }

  Widget buildBorrowerField(BuildContext context) {
    return buildUserTextField(
      context: context,
      title: AppLocalizations.of(context).privateLoanBorrower,
      selectTitle: AppLocalizations.of(context).privateLoanBorrowerSelect,
      controller: borrowerTextController,
      focusNode: borrowerFocus,
      user: borrowerUser,
      onSelectedUser: (user) => setState(() => this.borrowerUser = user),
    );
  }

  Widget buildLenderField(BuildContext context) {
    return buildUserTextField(
      context: context,
      title: AppLocalizations.of(context).privateLoanLender,
      selectTitle: AppLocalizations.of(context).privateLoanLenderSelect,
      controller: lenderTextController,
      focusNode: lenderFocus,
      user: lenderUser,
      onSelectedUser: (user) => setState(() => this.lenderUser = user),
    );
  }

  Widget buildUserTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String title,
    required String selectTitle,
    required User? user,
    required void onSelectedUser(User? user),
  }) {
    final onSelectedSelectUser = () async {
      final selectedUser = await pushPage<User?>(
        context,
        builder: (context) => UserChoicePage(
          title: selectTitle,
          selectedUser: user,
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
          onPressed: () => onSelectedSelectUser(),
        ),
      ),
      onChanged: (text) {
        final matchedUser = getMatchedUser(text);
        if (user != matchedUser) onSelectedUser(matchedUser);
      },
      validator: (value) {
        if (value!.trim().isEmpty)
          return AppLocalizations.of(context).privateLoanValidationFieldIsEmpty;
        return null;
      },
    );
  }

  User? getMatchedUser(String text) => users?.findFirstOrNull(
        (user) =>
            _equalsIgnoreCase(text, user.getCommonName(context)) ||
            _equalsIgnoreCase(text, user.displayName) ||
            _equalsIgnoreCase(text, user.email),
      );

  bool _equalsIgnoreCase(String? lhs, String? rhs) =>
      lhs?.toLowerCase() == rhs?.toLowerCase();

  Widget buildValidationMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        personsValidationMessage!,
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      controller: amountTextController,
      focusNode: amountFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).privateLoanAmount,
        suffix: Text(amount?.currency.symbols.first ?? ""),
      ),
      textAlign: TextAlign.end,
      readOnly: true,
      validator: (value) {
        if (this.amount == null)
          return AppLocalizations.of(context).privateLoanValidationFieldIsEmpty;
        if (this.amount!.amount! <= 0)
          return AppLocalizations.of(context)
              .privateLoanValidationAmountIsNegativeOrZero;
        return null;
      },
    );
  }

  Widget buildRepaidAmount(BuildContext context) {
    return TextFormField(
      controller: repaidAmountTextController,
      focusNode: repaidAmountFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).privateLoanRepaidAmount,
        suffix: Text(repaidAmount.currency.symbols.first),
      ),
      textAlign: TextAlign.end,
      readOnly: true,
      validator: (_) {
        if (this.repaidAmount.amount! < 0)
          return AppLocalizations.of(context)
              .privateLoanValidationAmountIsNegativeOrZero;
        if (this.repaidAmount.amount! > this.amount!.amount!)
          return AppLocalizations.of(context)
              .privateLoanValidationRepaidAmountGreaterThenAmount;
        return null;
      },
    );
  }

  Widget buildRemainingAmount(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).privateLoanRemainingAmount),
      trailing: Text((amount! - repaidAmount.amount).formatted),
      dense: true,
    );
  }

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      controller: titleTextController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).privateLoanTitle,
      ),
      validator: (value) {
        if (value!.trim().isEmpty)
          return AppLocalizations.of(context).privateLoanValidationFieldIsEmpty;
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
        labelText: AppLocalizations.of(context).privateLoanDate,
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
      onChanged: (date) => setState(() => this.date = date!),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(widget.submitText),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}
